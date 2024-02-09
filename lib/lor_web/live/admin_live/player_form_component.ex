defmodule LorWeb.AdminLive.PlayerFormComponent do
  @moduledoc false
  use LorWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:team_options, get_team_options())
      |> assign_form()
      |> allow_upload(:picture,
        accept: ~w(.jpg .jpeg .png)s,
        max_entries: 1,
        max_file_size: 2_000_000
      )

    {:ok, socket}
  end

  defp assign_form(%{assigns: %{live_action: :new}} = socket) do
    form =
      AshPhoenix.Form.for_create(Lor.Pros.Player, :create,
        api: Lor.Pros,
        as: "player"
      )
      |> to_form()

    socket
    |> assign(:form, form)
    |> assign(:label, "Create")
    |> assign(:old_entries, [])
  end

  defp assign_form(%{assigns: %{live_action: :edit, player_id: player_id}} = socket) do
    player = get_player!(player_id)

    form =
      AshPhoenix.Form.for_update(player, :update,
        api: Lor.Pros,
        as: "player"
      )
      |> to_form()

    old_entries =
      if player.picture do
        [%{ref: player.picture.id, url: player.picture.url}]
      else
        []
      end

    socket
    |> assign(:form, form)
    |> assign(:old_entries, old_entries)
    |> assign(:label, "Edit")
  end

  @impl true
  def handle_event("validate", %{"player" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    socket = assign(socket, :form, form)
    {:noreply, socket}
  end

  def handle_event("save", %{"player" => params}, socket) do
    entries =
      consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
        {:postpone, {path, entry}}
      end)

    case entries do
      [] ->
        # if old_entries length is 0 put logo_id to nil to delete it
        params =
          if(length(socket.assigns.old_entries) == 0) do
            Map.put(params, "picture_id", nil)
          end

        save_player(socket, params)

      [upload] ->
        save_player_with_picture(socket, params, upload)
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

  defp save_player(socket, params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, player} ->
        socket =
          socket
          |> put_flash(:info, "Saved player #{player.official_name}")
          |> push_patch(to: ~p"/admin/players")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp save_player_with_picture(socket, params, {path, entry}) do
    case s3_upload_picture(path, entry) do
      {:ok, s3_object} ->
        params = Map.put(params, "logo_id", s3_object.id)
        save_player(socket, params)

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  defp s3_upload_picture(path, entry) do
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

  defp get_player!(player_id) do
    player_id
    |> Lor.Pros.Player.get!()
    |> Lor.Pros.load!([:picture])
  end

  defp get_team_options do
    for team <- list_teams() do
      {team.name, team.id}
    end
  end

  defp list_teams do
    Lor.Pros.Team
    |> Ash.Query.sort([:name])
    |> Lor.Pros.read!()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <PC.field
          required
          field={@form[:official_name]}
          placeholder="faker"
          phx-debounce="blur"
          label="Name"
        />

        <PC.field field={@form[:record]} type="switch" phx-debounce="blur" label="Record replay" />

        <PC.field
          field={@form[:liquidpedia_url]}
          type="url"
          phx-debounce="blur"
          label="Liquidpedia Url"
        />

        <PC.field field={@form[:main_role]} placeholder="faker" phx-debounce="blur" label="Main Role" />

        <PC.field
          type="select"
          field={@form[:current_team_id]}
          options={@team_options}
          prompt="Select team"
        />

        <.live_images_input
          id="player-picture"
          wrapper_class="mb-6"
          label="Picture"
          upload_target={@myself}
          upload={@uploads.picture}
          old_entries={@old_entries}
        />

        <PC.button type="submit" label={@label} />
      </.form>
    </div>
    """
  end
end
