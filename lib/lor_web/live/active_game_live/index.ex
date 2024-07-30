defmodule LorWeb.ActiveGameLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:active_game, nil)
      |> assign(:active_games, list_active_games())
      |> assign(:form, to_form(%{}))
      |> assign(:live_game_modal?, false)
      |> assign(:spectate_modal?, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    if connected?(socket) do
      LorWeb.Endpoint.subscribe("active_game:created")
      LorWeb.Endpoint.subscribe("active_game:destroyed")
    end

    {:noreply, socket}
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
        put_flash(socket, :error, "Could not open #{modal} for this game")
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

  @impl true
  def handle_info(
        %{topic: "active_game:destroyed", event: "destroy", payload: %{data: active_game}},
        socket
      ) do
    socket =
      socket
      |> update(:active_games, fn active_games ->
        Enum.reject(active_games, &(&1.id == active_game.id))
      end)
      |> put_flash(:info, "Game terminated #{active_game.id}")

    {:noreply, socket}
  end

  def handle_info(
        %{topic: "active_game:created", event: "create_from_api", payload: %{data: active_game}},
        socket
      ) do
    socket =
      socket
      |> update(:active_games, fn active_games ->
        game = Ash.load!(active_game, [:pro_participants])
        [game | active_games]
      end)
      |> put_flash(:info, "Game started #{active_game.id}")

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
