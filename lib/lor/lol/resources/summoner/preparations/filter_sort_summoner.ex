defmodule Lor.Lol.Summoner.Preparations.FilterSortSummoner do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    query
    |> filter_by_platform_id()
    |> filter_by_search()
  end

  defp filter_by_platform_id(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{platform_id: platform_id} ->
        Ash.Query.filter(query, platform_id == ^platform_id)

      _ ->
        query
    end
  end

  defp filter_by_search(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{search: ""} ->
        query

      %{search: search} ->
        search = search <> "%"
        Ash.Query.filter(query, ilike(search, ^search) or ilike(riot_id, ^search))

      _ ->
        query
    end
  end
end
