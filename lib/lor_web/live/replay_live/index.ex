defmodule LorWeb.ReplayLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(after: nil)
      |> stream_configure(:participants, dom_id: &"participant-#{&1.id}")
      |> stream(:participants, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    page = list_participants(socket)
    last_record = List.last(page.results)
    keyset = last_record.__metadata__.keyset

    socket
    |> assign(after: keyset)
    |> stream(:participants, page.results)
  end

  defp list_participants(%{assigns: %{after: nil}}) do
    Lor.Lol.Participant.list_replays!(%{})
  end

  defp list_participants(%{assigns: %{after: keyset}}) do
    Lor.Lol.Participant.list_replays!(%{}, page: [after: keyset])
  end
end
