defmodule Lor.Pros.Team.Changes.Destroy do
  @moduledoc """
  Handle the destroy of a team.
  The team logo aka a s3 object should be destroyed.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.after_transaction(changeset, &handle_after_transaction/2)
  end

  # Try to destroy the logo after a team is deleted
  defp handle_after_transaction(_changeset, {:ok, team}) do
    if team.logo_id do
      team.logo_id
      |> Lor.S3.Object.get!()
      |> Lor.S3.Object.destroy!()
    end

    {:ok, team}
  end

  defp handle_after_transaction(_changeset, success_or_error_result) do
    success_or_error_result
  end
end
