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
    |> filter_by_record()
    |> Ash.Query.sort(current_team_name: :asc, normalized_name: :asc)
  end

  defp filter_by_normalized_name(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{normalized_name: ""} ->
        query

      %{normalized_name: normalized_name} ->
        Ash.Query.filter(query, trigram_similarity(normalized_name, ^normalized_name) > 0.4)

      _ ->
        query
    end
  end

  defp filter_by_record(query) do
    case Ash.Changeset.get_argument(query, :filter) do
      %{record: true} ->
        Ash.Query.filter(query, record == true)

      %{record: false} ->
        Ash.Query.filter(query, record == false)

      _ ->
        query
    end
  end
end
