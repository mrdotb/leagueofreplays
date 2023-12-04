defmodule Lor.Pros.CreateSummonersStep do
  @moduledoc """
  """
  use Reactor.Step

  require Logger

  @impl true
  def run(arguments, _context, _options) do
    platform_id = arguments.platform_id
    ugg_pros = arguments.ugg_pros
    existing_players = arguments.existing_players
    created_players = arguments.created_players

    players_map = create_players_map(existing_players, created_players)

    names = Enum.map(ugg_pros, & &1["current_ign"])
    existing_summoners = Lor.Lol.Summoner.by_names_and_platform_id!(names, platform_id)

    existing_summoners_set =
      existing_summoners
      |> Enum.map(& &1.name)
      |> MapSet.new()

    results = Enum.map(ugg_pros, &maybe_create_summoner(players_map, existing_summoners_set, &1))

    {:ok, results}
  end

  defp create_players_map(existing_players, created_players) do
    existing_players
    |> Kernel.++(created_players)
    |> Enum.reduce(%{}, fn player, acc ->
      Map.put(acc, player.normalized_name, player)
    end)
  end

  defp maybe_create_summoner(players_map, existing_summoners_set, ugg_pro) do
    if not MapSet.member?(existing_summoners_set, ugg_pro["current_ign"]) do
      # ugg name is wrong their region_id is platform_id
      platform_id = String.to_existing_atom(ugg_pro["region_id"])
      region = Lor.Lol.PlatformIds.fetch_region!(platform_id)

      with {:ok, summoner_data} <-
             Lor.Lol.Rest.fetch_summoner_by_name(platform_id, ugg_pro["current_ign"]),
           {:ok, account_data} <-
             Lor.Lol.Rest.fetch_account_by_puuid(region, summoner_data["puuid"]) do
        player = Map.get(players_map, ugg_pro["normalized_name"])
        Lor.Lol.Summoner.create_from_api(platform_id, summoner_data, account_data, player.id)
      end
    end
  end
end
