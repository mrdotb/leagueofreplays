defmodule Lor.Lol.Participant.Preparations.FilterSortReplay do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    query
    |> filter_player()
    |> Ash.Query.load([
      :opponent_participant,
      match: [:replay, :game_start],
      summoner: [
        player: [
          :picture,
          current_team: :logo
        ]
      ]
    ])
    |> Ash.Query.sort([inserted_at: :desc], prepend?: true)
  end

  defp filter_player(query) do
    Ash.Query.filter(query, not is_nil(summoner.player))
  end
end
