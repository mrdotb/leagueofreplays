defmodule Lor.Lol.ActiveGame.Changes.CreateFromApi do
  @moduledoc """
  Map the active game data to our representation.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    game_data = Ash.Changeset.get_argument(changeset, :active_game)
    IO.inspect(game_data)
    game_start_time = get_game_start_time(game_data["gameStartTime"])
    encryption_key = game_data["observers"]["encryptionKey"]
    participants = get_participants(game_data["participants"])

    params = %{
      id: "#{game_data["platformId"]}-#{game_data["gameId"]}",
      game_mode: game_data["gameMode"],
      game_start_time: game_start_time,
      encryption_key: encryption_key,
      participants: participants
    }

    Ash.Changeset.change_attributes(changeset, params)
  end

  defp get_game_start_time(timestamp) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.truncate(:second)
  end

  defp get_participants(participants) do
    Enum.map(participants, &map_participant/1)
  end

  defp map_participant(participant) do
    %{
      name: participant["summonerName"],
      puuid: participant["puuid"],
      summoners: [participant["spell1Id"], participant["spell2Id"]],
      team_id: participant["teamId"],
      champion_id: participant["championId"]
    }
  end
end
