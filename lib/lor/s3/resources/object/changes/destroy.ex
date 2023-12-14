defmodule Lor.S3.Object.Changes.Destroy do
  @moduledoc """
  Handles the delete of S3 objects.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.after_transaction(changeset, &handle_after_transaction/2)
  end

  # Try to delete the s3 object after the object is deleted locally
  defp handle_after_transaction(_changeset, {:ok, object} = success) do
    Lor.S3.Api.delete_object(object.bucket, object.key)
    success
  end

  defp handle_after_transaction(_changeset, success_or_error_result) do
    success_or_error_result
  end
end
