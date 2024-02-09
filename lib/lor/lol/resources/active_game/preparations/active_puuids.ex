defmodule Lor.Lol.ActiveGame.Preparations.ActivePuuids do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _, _) do
    platform_id = Ash.Changeset.get_argument(query, :platform_id)

    query
    |> Ash.Query.filter(platform_id == ^platform_id)
    |> Ash.Query.load([:participant_puuids])
  end
end
