defmodule Lor.Pros.Player.Changes.CreateFromUGG do
  @moduledoc """
  Map the player_data to our representation of a player.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    player_data = Ash.Changeset.get_argument(changeset, :player_data)
    current_team_id = Ash.Changeset.get_argument(changeset, :current_team_id)
    picture_id = Ash.Changeset.get_argument(changeset, :picture_id)

    params = %{
      current_team_id: current_team_id,
      picture_id: picture_id,
      normalized_name: player_data["normalized_name"],
      official_name: player_data["official_name"],
      main_role: player_data["main_role"]
    }

    Ash.Changeset.change_attributes(changeset, params)
  end
end
