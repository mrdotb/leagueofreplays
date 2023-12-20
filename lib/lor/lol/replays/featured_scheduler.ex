defmodule Lor.Lol.Replays.FeaturedScheduler do
  @moduledoc """
  Schedule games from the featured endpoint per platform_id.
  """
  use GenServer

  require Logger

  defstruct ~w(platform_id)a

  # Public API

  @doc """
  Start the Scheduler
  """

  def start_link({platform_id, name}) do
    GenServer.start_link(__MODULE__, platform_id, name: name)
  end

  # Callbacks

  @impl true
  def init(platform_id) do
    Logger.info("Start FeaturedScheduler platform_id #{inspect(platform_id)}")
    state = %__MODULE__{platform_id: platform_id}
    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    send(self(), :schedule)

    {:noreply, state}
  end

  @impl true
  def handle_info(:schedule, state) do
    case Lor.Lol.Rest.fetch_featured_game(state.platform_id) do
      {:ok, response} ->
        # client_refresh_interval = response["clientRefreshInterval"]
        game_list = response["gameList"]

        for game <- game_list,
            game["gameStartTime"] != 0,
            Lor.TimeHelpers.started_less_than_m_ago?(game["gameStartTime"], 5) do
          Lor.Lol.Replays.Manager.add(game)
        end

        Process.send_after(self(), :schedule, 30_000)

      {:error, _} ->
        nil
    end

    {:noreply, state}
  end
end
