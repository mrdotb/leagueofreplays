defmodule Lor.Lol.Replays.ProScheduler do
  @moduledoc """
  Given a particular platform_id query for the summoners in database
  and poll the spectator endpoint to find live game record
  """
  use GenServer

  require Logger

  defstruct ~w(platform_id)a

  @interval :timer.minutes(1)

  # Public API

  @doc "Start the Scheduler"
  def start_link({platform_id, name}) do
    GenServer.start_link(__MODULE__, platform_id, name: name)
  end

  # Callbacks

  @impl GenServer
  def init(platform_id) do
    Logger.info("Start Pro Scheduler for platform_id: #{platform_id}")

    state = %__MODULE__{platform_id: platform_id}

    send(self(), :fetch_active_games)

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:fetch_active_games, state) do
    Logger.info("Pro Scheduler fetch active games platform_id: #{state.platform_id}")

    active_puuids = Lor.Lol.ActiveGame.list_active_puuids!(state.platform_id)
    summoners = Lor.Lol.Summoner.list_pro_by_platform_id!(state.platform_id)
    summoners = Enum.reject(summoners, &(&1.puuid in active_puuids))

    for summoner <- summoners do
      with {:ok, game} <-
             Lor.Lol.Rest.fetch_active_game_by_summoners(
               state.platform_id,
               summoner.puuid
             ),
           true <- game["gameMode"] != "TFT" do
        Lor.Lol.Replays.Manager.add(game)
      end
    end

    Process.send_after(self(), :fetch_active_games, @interval)
    {:noreply, state}
  end
end
