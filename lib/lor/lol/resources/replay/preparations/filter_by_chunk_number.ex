# defmodule Lor.Lol.Replay.Preparations.FilterByChunkNumber do
#   use Ash.Resource.Preparation
#   require Ash.Query

# def prepare(query, _, _) do
#   chunk_number = Ash.Changeset.get_argument(query, :number)

#   Ash.Query.load(query, chunk: chunk_number)
# end
# end
