defmodule Lor.Lol.Participant.Preparations.FilterSortReplay do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    query
    |> Ash.Query.load([
      :opponent_participant,
      match: [:replay],
      summoner: [
        player: [
          :picture,
          current_team: :logo
        ]
      ]
    ])
    |> filter_player()
    |> filter_by_player()
    |> filter_replay()
    |> Ash.Query.sort([inserted_at: :desc], prepend?: true)
  end

  defp filter_player(query) do
    Ash.Query.filter(query, not is_nil(summoner.player))
  end

  defp filter_by_player(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{player_id: player_id} ->
        Ash.Query.filter(query, summoner.player.id == ^player_id)

      _ ->
        query
    end
  end

  defp filter_replay(query) do
    Ash.Query.filter(query, not is_nil(match.replay))
  end
end
