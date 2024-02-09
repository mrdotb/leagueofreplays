defmodule LorWeb.AdminLive.Index do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}, as: "job"))
      |> assign(:platform_ids, Lor.Lol.PlatformIds.values())

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"job" => %{"platform_id" => platform_id}}, socket) do
    job = Lor.Pros.ProWorker.new(%{"platform_id" => platform_id})

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
