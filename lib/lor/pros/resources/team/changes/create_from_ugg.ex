defmodule Lor.Pros.Team.Changes.CreateFromUGG do
  @moduledoc """
  Map the team_data to our representation of a team.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    team_data = Ash.Changeset.get_argument(changeset, :team_data)
    logo_id = Ash.Changeset.get_argument(changeset, :logo_id)

    name = team_data["current_team"]

    params = %{
      logo_id: logo_id,
      name: name
    }

    Ash.Changeset.change_attributes(changeset, params)
  end
end
