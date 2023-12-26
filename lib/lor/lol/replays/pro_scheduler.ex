defmodule Lor.Lol.Replays.ProScheduler do
  @moduledoc """
  Given a particular platform_id query for the summoners in database
  and poll the spectator endpoint to find live game record
  """
  use GenServer

  require Logger

  defstruct ~w(platform_id summoners)a

  # Public API

  @doc "Start the Scheduler"
  def start_link({platform_id, name}) do
    GenServer.start_link(__MODULE__, platform_id, name: name)
  end

  # Callbacks

  @impl GenServer
  def init(platform_id) do
    Logger.info("Start Scheduler for platform_id: #{platform_id}")

    state = %__MODULE__{platform_id: platform_id}

    {:ok, state, {:continue, :fetch_summoners}}
  end

  @impl GenServer
  def handle_continue(:fetch_summoners, state) do
    summoners = Lor.Lol.Summoner.list_pro_by_platform_id!(state.platform_id)
    send(self(), :fetch_active_games)
    {:noreply, %{state | summoners: summoners}}
  end

  @impl GenServer
  def handle_info(:fetch_active_games, state) do
    for summoner <- state.summoners do
      with {:ok, game} <-
             Lor.Lol.Rest.fetch_active_game_by_summoners(
               state.platform_id,
               summoner.encrypted_id
             ),
           true <- game["gameStartTime"] != 0,
           true <- Lor.TimeHelpers.started_less_than_m_ago?(game["gameStartTime"], 5) do
        Lor.Lol.Replays.Manager.add(game)
      end
    end

    send(self(), :fetch_active_games)
    {:noreply, state}
  end
end
