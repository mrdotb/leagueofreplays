defmodule LorWeb.AdminLive.DeleteReplays do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}, as: "job"))
      |> assign(:game_versions, Lor.Lol.Replay.list_game_version!())

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"job" => %{"game_version" => game_version}}, socket) do
    job = Lor.Lol.DeleteReplayWorker.new(%{"game_version" => game_version})

    socket =
      case Oban.insert(job) do
        {:ok, _job} ->
          put_flash(socket, :info, "Job enqueued")

        {:error, _} ->
          put_flash(socket, :error, "Could not enqueue job")
      end

    {:noreply, socket}
  end
end
