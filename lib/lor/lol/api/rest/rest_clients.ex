defmodule Lor.Lol.RestClients do
  @moduledoc """
  A Agent that wrap tesla clients for each region.
  """

  use Agent

  # Public API

  @doc "Start"
  def start_link(_opts) do
    Agent.start_link(
      fn ->
        platform_ids = Lor.Lol.PlatformIds.values()
        regions = Lor.Lol.Regions.values()

        routes = platform_ids ++ regions

        for route <- routes, reduce: %{} do
          acc ->
            client = Lor.Lol.Rest.new(route)
            Map.put(acc, route, client)
        end
      end,
      name: __MODULE__
    )
  end

  def get_client(region_or_platform_id) do
    Agent.get(__MODULE__, &Map.get(&1, region_or_platform_id))
  end
end
