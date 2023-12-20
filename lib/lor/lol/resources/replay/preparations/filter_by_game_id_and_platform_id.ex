defmodule Lor.Lol.Replay.Preparations.FilterByGameIdAndPlatformId do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    platform_id = Ash.Changeset.get_argument(query, :platform_id)
    game_id = Ash.Changeset.get_argument(query, :game_id)

    Ash.Query.filter(query, platform_id == ^platform_id and game_id == ^game_id)
  end
end
