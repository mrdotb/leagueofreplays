defmodule Lor.Pros.Player.Changes.Update do
  @moduledoc """
  Handle the update of a player.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.before_transaction(&handle_before_transaction/1)
    |> Ash.Changeset.after_transaction(&handle_after_transaction/2)
  end

  defp handle_before_transaction(changeset) do
    changeset
    |> Ash.Changeset.put_context(:picture_id, changeset.data.picture_id)
    |> Ash.Changeset.put_context(:picture, changeset.data.picture)
  end

  defp handle_after_transaction(
         %{context: %{picture_id: picture_id, picture: picture}},
         {:ok, player}
       )
       when is_binary(picture_id) do
    if picture_id != player.picture_id do
      Lor.S3.Object.destroy!(picture)
    end

    {:ok, player}
  end

  defp handle_after_transaction(_changeset, success_or_error_result) do
    success_or_error_result
  end
end
