defmodule Lor.Lol.Replays.Manager do
  @moduledoc """
  GenServer which stores aggregates and stores state for all replays worker processes.
  """
  use GenServer

  require Logger

  # Public API

  @doc "Start the Manager"
  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @doc "Add a an active game"
  def add(active_game), do: GenServer.call(__MODULE__, {:add, active_game})

  # Callbacks

  @impl GenServer
  def init(_args) do
    {:ok, %{}, {:continue, :restore}}
  end

  @impl GenServer
  def handle_continue(:restore, state) do
    state =
      %{}
      |> Lor.Lol.ActiveGame.list!()
      |> Enum.reduce(state, fn active_game, state ->
        args = %{
          id: active_game.id,
          manager_pid: self(),
          platform_id: active_game.platform_id,
          game_id: active_game.game_id,
          encryption_key: active_game.encryption_key,
          action: :restore
        }

        {:ok, pid} = Lor.Lol.Replays.WorkerSupervisor.add(args)
        Map.put(state, active_game.id, pid)
      end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:add, active_game}, _from, state) do
    id = get_id(active_game)

    {:ok, platform_id} = Lor.Lol.PlatformIds.match(active_game["platformId"])
    game_id = active_game["gameId"]
    encryption_key = active_game["observers"]["encryptionKey"]

    state =
      if not Map.has_key?(state, id) do
        args = %{
          id: id,
          manager_pid: self(),
          platform_id: platform_id,
          game_id: game_id,
          encryption_key: encryption_key,
          action: :start
        }

        {:ok, pid} = Lor.Lol.Replays.WorkerSupervisor.add(args)
        Lor.Lol.ActiveGame.create_from_api!(active_game)

        Map.put(state, id, pid)
      else
        state
      end

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info({:terminating, ending_state}, state) do
    Logger.info("Manager received terminating ending_state: #{inspect(ending_state)}")
    state = Map.delete(state, ending_state.id)

    ending_state.id
    |> Lor.Lol.ActiveGame.get!()
    |> Lor.Lol.ActiveGame.destroy!()

    {:noreply, state}
  end

  defp get_id(active_game) do
    "#{active_game["platformId"]}-#{active_game["gameId"]}"
  end
end
