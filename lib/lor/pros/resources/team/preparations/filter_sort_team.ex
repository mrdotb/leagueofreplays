defmodule Lor.Pros.Team.Preparations.FilterSortTeam do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    query
    |> Ash.Query.load([:logo, :players, :players_count])
    |> filter_by_name()
    |> Ash.Query.sort(inserted_at: :desc)
  end

  defp filter_by_name(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{name: ""} ->
        query

      %{name: name} ->
        Ash.Query.filter(query, trigram_similarity(name, ^name) > 0.4)
    end
  end
end
