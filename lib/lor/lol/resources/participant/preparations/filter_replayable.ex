defmodule Lor.Lol.Participant.Preparations.FilterReplayable do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    kda = Ash.Changeset.get_argument(query, :kda)

    query
    |> Ash.Query.load([
      :kda,
      match: [replay: :complete],
      opponent_participant: [summoner: :player],
      summoner: [
        player: :current_team
      ]
    ])
    |> Ash.Query.filter(not is_nil(summoner.player))
    |> Ash.Query.filter(not is_nil(match.replay))
    |> Ash.Query.filter(match.replay.complete == true)
    |> Ash.Query.filter(kda > ^kda)
    |> Ash.Query.sort(inserted_at: :desc)
  end
end
