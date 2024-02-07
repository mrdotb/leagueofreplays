defmodule Lor.Lol.Replay.Preparations.FilterByState do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    state = Ash.Changeset.get_argument(query, :state)

    query
    |> Ash.Query.load([:match, key_frames: :data, chunks: :data])
    |> Ash.Query.filter(state == ^state)
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.Query.limit(1)
  end
end
