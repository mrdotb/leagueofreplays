defmodule Lor.Pros.Player.Changes.Destroy do
  @moduledoc """
  Handle the destroy of a player.
  The player picture aka a s3 object should be destroyed.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.after_transaction(changeset, &handle_after_transaction/2)
  end

  # Try to destroy the picture after a player is deleted
  defp handle_after_transaction(_changeset, {:ok, player}) do
    if player.picture_id do
      player.picture_id
      |> Lor.S3.Object.get!()
      |> Lor.S3.Object.destroy!()
    end

    {:ok, player}
  end

  defp handle_after_transaction(_changeset, success_or_error_result) do
    success_or_error_result
  end
end
