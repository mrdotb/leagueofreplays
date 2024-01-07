defmodule Lor.Lol.Match.Changes.CreateFromApi do
  @moduledoc """
  Map the match_data to our represetation of a match.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    match_data = Ash.Changeset.get_argument(changeset, :match_data)
    metadata = match_data["metadata"]
    info = match_data["info"]

    s3_object_id = Ash.Changeset.get_argument(changeset, :s3_object_id)
    game_start = get_game_start(info["gameStartTimestamp"])

    params = %{
      original_data_id: s3_object_id,
      data_version: metadata["dataVersion"],
      match_id: metadata["matchId"],
      participant_puuids: metadata["participants"],
      game_creation: info["gameCreation"],
      game_duration: info["gameDuration"],
      game_start_timestamp: info["gameStartTimestamp"],
      game_end_timestamp: info["gameEndTimestamp"],
      game_id: info["gameId"],
      game_mode: info["gameMode"],
      game_name: info["gameName"],
      game_type: info["gameType"],
      game_version: info["gameVersion"],
      map_id: info["mapId"],
      queue_id: info["queueId"],
      platform_id: info["platformId"],
      game_start: game_start
    }

    Ash.Changeset.change_attributes(changeset, params)
  end

  defp get_game_start(game_start_timestamp) do
    game_start_timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.truncate(:second)
  end
end
