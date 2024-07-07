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

  # https://developer.riotgames.com/apis#match-v5
  @platform_ids_match_routing_map %{
    na1: :AMERICAS,
    br1: :AMERICAS,
    la1: :AMERICAS,
    la2: :AMERICAS,
    kr: :ASIA,
    jp1: :ASIA,
    tw2: :SEA,
    th2: :SEA,
    vn2: :SEA,
    sg2: :SEA,
    ph2: :SEA,
    eun1: :EUROPE,
    euw1: :EUROPE,
    eu1: :EUROPE,
    tr1: :EUROPE,
    ru: :EUROPE,
    oc1: :SEA
  }

  # https://developer.riotgames.com/apis#account-v1
  @platform_ids_account_routing_map %{
    na1: :AMERICAS,
    br1: :AMERICAS,
    la1: :AMERICAS,
    la2: :AMERICAS,
    kr: :ASIA,
    jp1: :ASIA,
    tw2: :ASIA,
    th2: :ASIA,
    vn2: :ASIA,
    sg2: :ASIA,
    ph2: :ASIA,
    eun1: :EUROPE,
    euw1: :EUROPE,
    eu1: :EUROPE,
    tr1: :EUROPE,
    ru: :EUROPE,
    oc1: :ASIA
  }

  def fetch_region!(platform_id, :match) do
    Map.fetch!(@platform_ids_match_routing_map, platform_id)
  end

  def fetch_region!(platform_id, :account) do
    Map.fetch!(@platform_ids_account_routing_map, platform_id)
  end
end
