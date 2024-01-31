defmodule LorWeb.AdminLive.Summoners do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:game_version, Lor.Lol.Ddragon.get_last_game_version())
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

  defp apply_action(socket, :attach, %{"player_id" => player_id}) do
    socket
    |> assign(:player_id, player_id)
  end

  @impl true
  def handle_event("detach", %{"id" => id}, %{assigns: %{player_id: player_id}} = socket) do
    id
    |> Lor.Lol.Summoner.get!()
    |> Lor.Lol.Summoner.detach!()

    socket = push_patch(socket, to: ~p"/admin/players/#{player_id}/summoners")
    {:noreply, socket}
  end

  def handle_event("close_modal", _, %{assigns: %{player_id: player_id}} = socket) do
    socket = push_patch(socket, to: ~p"/admin/players/#{player_id}/summoners")
    {:noreply, socket}
  end

  defp list_summoners!(player_id) do
    Lor.Lol.Summoner.list_by_player_id!(player_id)
  end
end
