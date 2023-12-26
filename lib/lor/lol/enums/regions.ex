defmodule Lor.Lol.Regions do
  @moduledoc """
  The region routing values from
  https://developer.riotgames.com/docs/lol#routing-values_platform-routing-values
  """
  use Ash.Type.Enum, values: [:AMERICAS, :ASIA, :EUROPE, :SEA]

  @regions_routing_map %{
    :AMERICAS => ~w(na1 br1 la1 la2)a,
    :ASIA => ~w(kr jp1)a,
    :EUROPE => ~w(eun1 eu1 tr1 ru)a,
    :SEA => ~w(oc1 tw2 th2 vn2)a
  }

  def get_platform_ids(region), do: Map.get(@regions_routing_map, region)
end
