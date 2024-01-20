defmodule LorWeb.ActiveGameLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}))
      |> assign(:active_games, list_active_games())
      |> assign(:active_game, list_active_games() |> List.first())
      |> assign(:spectate_modal?, false)
      |> assign(:live_game_modal?, true)

    {:ok, socket}
  end

  @impl true
  def handle_event("show-modal", %{"modal" => modal, "id" => id}, socket) do
    active_game = Enum.find(socket.assigns.active_games, &(&1.id == id))

    modal_key =
      case modal do
        "spectate" -> :spectate_modal?
        "live-game" -> :live_game_modal?
      end

    socket =
      if is_struct(active_game) do
        socket
        |> assign(modal_key, true)
        |> assign(:active_game, active_game)
      else
        put_flash(socket, :info, "Could not open #{modal} for this game")
      end

    {:noreply, socket}
  end

  def handle_event("close_modal", _, socket) do
    socket =
      socket
      |> assign(:spectate_modal?, false)
      |> assign(:live_game_modal?, false)
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
