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
    |> filter_by_normalized_name()
    |> Ash.Query.sort(current_team_name: :asc, normalized_name: :asc)
  end

  defp filter_by_normalized_name(query) do
    IO.inspect(query)

    case Ash.Changeset.get_argument(query, :filter) do
      %{normalized_name: ""} ->
        query

      %{normalized_name: normalized_name} ->
        normalized_name = normalized_name <> "%"
        Ash.Query.filter(query, ilike(normalized_name, ^normalized_name))
    end
  end
end
