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
    # Todo aggregate
    # Process.send_after(self(), :fetch_all, @update_interval)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:add, active_game}, _from, state) do
    id = get_id(active_game)

    {:ok, platform_id} = Lor.Lol.PlatformIds.match(active_game["platformId"])

    state =
      if not Map.has_key?(state, id) do
        args = %{
          id: id,
          manager_pid: self(),
          platform_id: platform_id,
          active_game: active_game
        }

        {:ok, pid} = Lor.Lol.Replays.WorkerSupervisor.add(args)
        Map.put(state, id, %{pid: pid, active_game: active_game})
      else
        state
      end

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info({:terminating, ending_state}, state) do
    Logger.info("Manager received terminating ending_state: #{inspect(ending_state)}")
    {:noreply, state}
  end

  defp get_id(active_game) do
    "#{active_game["platformId"]}-#{active_game["gameId"]}"
  end
end
