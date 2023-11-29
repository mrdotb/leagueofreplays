defmodule Lor.Lol.Summoner.Changes.CreateFromApi do
  @moduledoc """
  Map the summoner_data and account_date to our representation of a summoner.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    summoner_data = Ash.Changeset.get_argument(changeset, :summoner_data)
    account_data = Ash.Changeset.get_argument(changeset, :account_data)

    params = %{
      riot_id: to_riot_id(account_data),
      name: summoner_data["name"],
      account_id: summoner_data["accountId"],
      encrypted_id: summoner_data["id"],
      puuid: summoner_data["puuid"],
      profile_icon_id: summoner_data["profileIconId"],
      revision_date: summoner_data["revisionDate"],
      summoner_level: summoner_data["summonerLevel"]
    }

    Ash.Changeset.change_attributes(changeset, params)
  end

  defp to_riot_id(account_data) do
    game_name = account_data["gameName"]
    tag_line = account_data["tagLine"]

    "#{game_name}##{tag_line}"
  end
end
