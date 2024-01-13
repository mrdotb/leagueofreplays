defmodule Lor.Pros.Player.Preparations.FilterSortPlayer do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    query
    |> Ash.Query.load([
      :picture,
      :summoners,
      :current_team_name,
      current_team: :logo
    ])
    |> Ash.Query.sort(current_team_name: :asc, normalized_name: :asc)
  end
end
