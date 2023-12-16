defmodule Lor.Lol.Observer.Clients do
  @moduledoc """
  A GenServer that wrap all clients for each region.
  """

  use GenServer

  # Public API

  @doc "Start"
  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def get_client(platform_id) do
    GenServer.call(__MODULE__, {:get_client, platform_id})
  end

  # Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{}, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    platform_ids = Lor.Lol.PlatformIds.values()

    state =
      for platform_id <- platform_ids, reduce: state do
        acc ->
          client = Lor.Lol.Observer.Client.new(platform_id)
          Map.put(acc, platform_id, client)
      end

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_client, region_or_platform_id}, _from, state) do
    client = Map.get(state, region_or_platform_id)
    {:reply, client, state}
  end
end
