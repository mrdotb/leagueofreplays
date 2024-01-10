defmodule Lor.Lol.Replays do
  @moduledoc """
  GenServer to access the replays ets table.
  """
  use GenServer

  require Logger

  @doc "Start Replays"
  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @doc "List all replays"
  def list, do: GenServer.call(__MODULE__, :list)

  # Callbacks

  def init(_args) do
    opts = [:ordered_set, :named_table, :protected, read_concurrency: true]
    :ets.new(:replays, opts)
    {:ok, []}
  end

  def handle_cast({:insert, active_game}, _from, state) do
    Lor.Lol.ActiveGame.create_from_api(active_game)
    {:noreply, state}
  end

  def handle_call(:list, _from, state) do
    reply = :ets.tab2list(:replays)
    {:reply, reply, state}
  end

  def handle_call({:fetch, id}, _from, state) do
    reply =
      case :ets.lookup(:replays, id) do
        [{_id, data}] ->
          {:ok, data}

        [] ->
          {:error, :not_found}
      end

    {:reply, reply, state}
  end
end
