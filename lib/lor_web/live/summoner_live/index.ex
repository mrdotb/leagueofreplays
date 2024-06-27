defmodule LorWeb.SummonerLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:summoners, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"player_id" => player_id}) do
    summoners = list_summoners!(player_id)

    socket
    |> assign(:player_id, player_id)
    |> assign(:summoners, summoners)
  end

  defp list_summoners!(player_id) do
    Lor.Lol.Summoner.list_by_player_id!(player_id)
  end
end
