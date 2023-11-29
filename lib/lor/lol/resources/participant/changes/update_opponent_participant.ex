defmodule Lor.Lol.Participant.Changes.UpdateOpponentParticipant do
  @moduledoc """
  Find the opponent participant in the other team based on role if no
  participant is found the changeset is unchanged.
  Some modes and in some specific case the team_position is null.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    if is_nil(Ash.Changeset.get_data(changeset, :team_position)) do
      changeset
    else
      Ash.Changeset.change_attribute(
        changeset,
        :opponent_participant_id,
        find_opponent_participant_id(changeset)
      )
    end
  end

  defp find_opponent_participant_id(changeset) do
    participants = Ash.Changeset.get_argument(changeset, :participants)
    team_id = Ash.Changeset.get_data(changeset, :team_id)
    team_position = Ash.Changeset.get_data(changeset, :team_position)
    opponent_team_id = get_opponent_team_id(team_id)

    opponent_participant =
      Enum.find(participants, fn participant ->
        participant.team_id == opponent_team_id and
          participant.team_position == team_position
      end)

    if opponent_participant do
      opponent_participant.id
    end
  end

  defp get_opponent_team_id(100), do: 200
  defp get_opponent_team_id(200), do: 100
end
