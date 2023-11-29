defmodule Lor.Lol.PlatformIds do
  @moduledoc """
  The platform_id routing values from
  https://developer.riotgames.com/docs/lol#routing-values_platform-routing-values
  """
  use Ash.Type.Enum,
    values: [
      :br1,
      :eun1,
      :euw1,
      :jp1,
      :kr,
      :la1,
      :la2,
      :na1,
      :oc1,
      :tr1,
      :ru,
      :ph2,
      :sg2,
      :th2,
      :tw2,
      :vn2
    ]

  @platform_ids_routing_map %{
    na1: :AMERICAS,
    br1: :AMERICAS,
    la1: :AMERICAS,
    la2: :AMERICAS,
    kr: :ASIA,
    jp1: :ASIA,
    tw2: :ASIA,
    th2: :ASIA,
    vn2: :ASIA,
    eun1: :EUROPE,
    eu1: :EUROPE,
    tr1: :EUROPE,
    ru: :EUROPE,
    oc1: :SEA
  }

  def get_region(platform_id), do: Map.get(@platform_ids_routing_map, platform_id)
end
