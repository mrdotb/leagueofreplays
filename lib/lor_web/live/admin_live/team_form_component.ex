defmodule LorWeb.AdminLive.TeamFormComponent do
  @moduledoc false
  use LorWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form()
      |> allow_upload(:logo,
        accept: ~w(.jpg .jpeg .png)s,
        max_entries: 1,
        max_file_size: 2_000_000
      )

    {:ok, socket}
  end

  defp assign_form(%{assigns: %{live_action: :new}} = socket) do
    form =
      AshPhoenix.Form.for_create(Lor.Pros.Team, :create,
        domain: Lor.Pros,
        as: "team"
      )
      |> to_form()

    socket
    |> assign(:form, form)
    |> assign(:label, "Create")
    |> assign(:old_entries, [])
  end

  defp assign_form(%{assigns: %{live_action: :edit, team_id: team_id}} = socket) do
    team = get_team!(team_id)

    form =
      AshPhoenix.Form.for_update(team, :update,
        domain: Lor.Pros,
        as: "team"
      )
      |> to_form()

    old_entries =
      if team.logo do
        [%{ref: team.logo.id, url: team.logo.url}]
      else
        []
      end

    socket
    |> assign(:form, form)
    |> assign(:old_entries, old_entries)
    |> assign(:label, "Edit")
  end

  @impl true
  def handle_event("validate", %{"team" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    socket = assign(socket, :form, form)
    {:noreply, socket}
  end

  def handle_event("save", %{"team" => params}, socket) do
    entries =
      consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
        {:postpone, {path, entry}}
      end)

    case entries do
      [] ->
        # if old_entries length is 0 put logo_id to nil to delete it
        params =
          if(length(socket.assigns.old_entries) == 0) do
            Map.put(params, "logo_id", nil)
          end

        save_team(socket, params)

      [upload] ->
        save_team_with_logo(socket, params, upload)
    end
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  def handle_event("delete_entry", %{"ref" => ref}, socket) do
    socket =
      update(socket, :old_entries, fn old_entries, _assigns ->
        Enum.reject(old_entries, &(&1.ref == ref))
      end)

    {:noreply, socket}
  end

  defp save_team(socket, params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, team} ->
        socket =
          socket
          |> put_flash(:info, "Saved team #{team.name}")
          |> push_patch(to: ~p"/admin/teams")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp save_team_with_logo(socket, params, {path, entry}) do
    case s3_upload_logo(path, entry) do
      {:ok, s3_object} ->
        params = Map.put(params, "logo_id", s3_object.id)
        save_team(socket, params)

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  defp s3_upload_logo(path, entry) do
    bucket = Application.get_env(:lor, :s3).buckets.pictures
    key = "team/#{entry.uuid}-#{entry.client_name}"

    body = File.read!(path)

    params = %{
      bucket: bucket,
      key: key,
      content_type: entry.client_type,
      file_name: entry.client_name
    }

    Lor.S3.Object.upload(body, true, params)
  end

  defp get_team!(team_id) do
    team_id
    |> Lor.Pros.Team.get!()
    |> Ash.load!([:logo])
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <PC.field
          required
          field={@form[:name]}
          placeholder="SK telecom"
          phx-debounce="blur"
          label="Name"
        />

        <PC.field field={@form[:short_name]} placeholder="SKT" phx-debounce="blur" label="Short name" />

        <.live_images_input
          id="team-logo"
          wrapper_class="mb-6"
          label="Logo"
          upload_target={@myself}
          upload={@uploads.logo}
          old_entries={@old_entries}
        />

        <PC.button type="submit" label={@label} />
      </.form>
    </div>
    """
  end
end
