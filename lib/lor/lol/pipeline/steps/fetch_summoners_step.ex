defmodule Lor.Lol.FetchSummonersStep do
  @moduledoc """
  Fetch existing_summoners in the database and the one we are missing from the
  riot api.
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    match_data = arguments.match_data
    participant_puuids = match_data["metadata"]["participants"]

    summoners = Lor.Lol.Summoner.by_puuids!(participant_puuids)
    existing_summoner_puuids = Enum.map(summoners, & &1.puuid)
    puuids_to_create = Enum.reject(participant_puuids, &(&1 in existing_summoner_puuids))

    summoners_to_create =
      for puuid <- puuids_to_create do
        {:ok, summoner_data} = Lor.Lol.Rest.fetch_summoner_by_puuid(arguments.platform_id, puuid)
        {:ok, account_data} = Lor.Lol.Rest.fetch_account_by_puuid(arguments.region, puuid)
        %{summoner_data: summoner_data, account_data: account_data}
      end

    result = %{
      existing_summoners: summoners,
      summoners_to_create: summoners_to_create
    }

    {:ok, result}
  end
end
