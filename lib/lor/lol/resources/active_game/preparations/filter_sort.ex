defmodule Lor.Lol.ActiveGame.Preparations.FilterSort do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    query
    |> Ash.Query.load([:pro_participants])
    |> Ash.Query.sort(game_start_time: :desc)
  end
end
