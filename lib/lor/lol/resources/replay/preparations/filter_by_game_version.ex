defmodule Lor.Lol.Replay.Preparations.FilterByGameVersion do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    game_version = Ash.Changeset.get_argument(query, :game_version)

    query
    |> Ash.Query.load([:match, key_frames: :data, chunks: :data])
    |> Ash.Query.filter(match.game_version == ^game_version)
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.Query.limit(1)
  end
end
