defmodule Lor.Lol.Summoner.Preparations.FilterSortSummoner do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    query
    |> filter_by_platform_id()
    |> filter_by_name()
  end

  defp filter_by_platform_id(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{platform_id: platform_id} ->
        Ash.Query.filter(query, platform_id == ^platform_id)

      _ ->
        query
    end
  end

  defp filter_by_name(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{name: ""} ->
        query

      %{name: name} ->
        name = name <> "%"
        Ash.Query.filter(query, ilike(name, ^name))

      _ ->
        query
    end
  end
end
