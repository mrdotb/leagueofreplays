defmodule Lor.Pros.FetchTeamsStep do
  @moduledoc """
  Fetch existing_teams from the database and compare what we should create from
  UGG.
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    ugg_pros = arguments.ugg_pros

    teams_data =
      ugg_pros
      |> Enum.uniq_by(& &1["current_team"])
      |> Enum.map(&Map.take(&1, ["current_team", "team_picture"]))

    names = Enum.map(teams_data, & &1["current_team"])

    existing_teams = Lor.Pros.Team.by_names!(names)

    existing_team_names_set =
      existing_teams
      |> Enum.map(& &1.name)
      |> MapSet.new()

    teams_to_create =
      Enum.reject(
        teams_data,
        &MapSet.member?(existing_team_names_set, &1["current_team"])
      )

    result = %{
      existing_teams: existing_teams,
      teams_to_create: teams_to_create
    }

    {:ok, result}
  end
end
