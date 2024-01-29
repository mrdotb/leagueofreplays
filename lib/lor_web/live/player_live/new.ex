defmodule LorWeb.PlayerLive.New do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    socket = allow_upload(socket, :picture, accept: ~w(.jpg .jpeg .png)s, max_entries: 1)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _) do
    form =
      AshPhoenix.Form.for_create(Lor.Pros.Player, :create,
        api: Lor.Pros,
        as: "player"
      )
      |> to_form()

    socket
    |> assign(:team_options, get_team_options())
    |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"player" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    socket = assign(socket, :form, form)
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :picture, ref)}
  end

  def handle_event("save", %{"player" => params}, socket) do
    entries =
      consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
        {:postpone, {path, entry}}
      end)

    case entries do
      [] ->
        save(params, socket)

      [upload] ->
        save_with_upload(upload, params, socket)
    end
  end

  defp save(params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, player} ->
        socket =
          socket
          |> put_flash(:info, "Saved player #{player.official_name}")
          |> redirect(to: ~p"/admin/players")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp save_with_upload({path, entry}, params, socket) do
    case s3_upload_picture(path, entry) do
      {:ok, s3_object} ->
        params
        |> Map.put("picture_id", s3_object.id)
        |> save(socket)

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  defp s3_upload_picture(path, entry) do
    bucket = Application.get_env(:lor, :s3).buckets.pictures
    key = "player/#{entry.client_name}"

    body = File.read!(path)

    params = %{
      bucket: bucket,
      key: key,
      content_type: entry.client_type,
      file_name: entry.client_name
    }

    Lor.S3.Object.upload(body, true, params)
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
end
