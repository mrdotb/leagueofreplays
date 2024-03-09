defmodule Lor.Lol.Replay.Actions.ListGameVersions do
  use Ash.Resource.Actions.Implementation

  import Ecto.Query

  def run(_input, _opts, _context) do
    query =
      from replay in Lor.Lol.Replay,
        inner_join: match in Lor.Lol.Match,
        on: replay.match_id == match.id,
        distinct: match.game_version,
        order_by: match.game_version,
        select: match.game_version

    {:ok, Lor.Repo.all(query)}
  end
end
