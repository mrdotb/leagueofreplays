defmodule Lor.Lol.Replays.ActiveGames do
  @moduledoc """
  GenServer to manage the active games.
  """
  use GenServer

  @table :active_games
  @topic "active_games"

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def insert(id, active_game), do: GenServer.cast(__MODULE__, {:insert, id, active_game})

  def delete(id), do: GenServer.cast(__MODULE__, {:delete, id})

  # Direct ets read functions

  def list do
    :ets.tab2list(@table)
  end

  def fetch(id) do
    case :ets.lookup(@table, id) do
      [{_id, data}] ->
        {:ok, data}

      [] ->
        {:error, :not_found}
    end
  end

  # Callbacks

  def init(_args) do
    opts = [:ordered_set, :named_table, :protected, read_concurrency: true]
    :ets.new(@table, opts)
    {:ok, []}
  end

  def handle_cast({:insert, id, active_game}, state) do
    :ets.insert(@table, {id, active_game})
    Phoenix.PubSub.broadcast(:lor_pubsub, @topic, {:start, id})
    {:noreply, state}
  end

  def handle_cast({:delete, id}, state) do
    :ets.delete(@table, id)
    Phoenix.PubSub.broadcast(:lor_pubsub, @topic, {:end, id})
    {:noreply, state}
  end
end
