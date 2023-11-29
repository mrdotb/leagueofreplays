defmodule Lor.Lol.Participant.Changes.CreateFromApi do
  @moduledoc """
  Map the participant_data to our representation of participant.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    participant_data = Ash.Changeset.get_argument(changeset, :participant_data)
    existing_summoners = Ash.Changeset.get_argument(changeset, :existing_summoners)
    created_summoners = Ash.Changeset.get_argument(changeset, :created_summoners)

    summoners_map =
      existing_summoners
      |> Kernel.++(created_summoners)
      |> Enum.map(&{&1.puuid, &1.id})
      |> Map.new()

    params = %{
      summoner_id: Map.get(summoners_map, participant_data["puuid"]),
      team_id: participant_data["teamId"],
      kills: participant_data["kills"],
      deaths: participant_data["deaths"],
      assists: participant_data["assists"],
      champion_id: participant_data["championId"],
      gold_earned: participant_data["goldEarned"],
      summoners: [
        participant_data["summoner1Id"],
        participant_data["summoner2Id"]
      ],
      items: [
        participant_data["item0"],
        participant_data["item1"],
        participant_data["item2"],
        participant_data["item3"],
        participant_data["item4"],
        participant_data["item5"],
        participant_data["item6"]
      ],
      team_position: participant_data["teamPosition"]
    }

    Ash.Changeset.change_attributes(changeset, params)
  end
end
