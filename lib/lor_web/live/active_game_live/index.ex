defmodule LorWeb.ActiveGameLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}))
      |> assign(:active_games, list_active_games())
      |> assign(:active_game, nil)
      |> assign(:show_modal?, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("show-modal", %{"id" => id}, socket) do
    active_game =
      socket.assigns.active_games
      |> Enum.find(fn active_game ->
        active_game.id == id
      end)

    socket =
      socket
      |> assign(:show_modal?, true)
      |> assign(:active_game, active_game)

    {:noreply, socket}
  end

  def handle_event("close_modal", _, socket) do
    socket =
      socket
      |> assign(:show_modal?, false)
      |> assign(:active_game, nil)

    {:noreply, socket}
  end

  defp list_active_games do
    Lor.Lol.ActiveGame.list!(nil)
  end

  defp spectate_params(active_game) do
    active_game
    |> Map.take([:platform_id, :game_id, :encryption_key])
    |> Map.put(:endpoint, "riot")
  end
end
