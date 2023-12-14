defmodule Lor.S3.Object.Changes.Upload do
  @moduledoc """
  Handles the upload of objects to S3.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.before_transaction(&handle_before_transaction/1)
    |> Ash.Changeset.after_transaction(&handle_after_transaction/2)
  end

  defp handle_before_transaction(changeset) do
    body = Ash.Changeset.get_argument(changeset, :body)
    bucket = changeset.attributes.bucket
    key = changeset.attributes.key

    url = if(Ash.Changeset.get_argument(changeset, :set_url?), do: Lor.S3.Api.url(bucket, key))
    md5 = Lor.S3.Utils.hash_bin_md5(body)
    size = byte_size(body)

    input = %{
      body: body,
      content_type: changeset.attributes.content_type,
      md5: md5
    }

    case Lor.S3.Api.put_object(bucket, key, input) do
      {:ok, _response} ->
        changeset
        |> Ash.Changeset.force_change_attributes(%{md5: md5, size: size, url: url})
        |> Ash.Changeset.put_context(:upload_successful?, true)

      {:error, _error} ->
        changeset
        |> Ash.Changeset.add_error(field: :body, message: "The upload failed.")
        |> Ash.Changeset.put_context(:upload_successful?, false)
    end
  end

  # If the upload was successful but there is another error that prevent
  # the insert try to delete the object
  defp handle_after_transaction(
         _changeset,
         {:error, %{context: %{upload_successful?: true}} = changeset} = error_result
       ) do
    bucket = changeset.attributes.bucket
    key = changeset.attributes.key
    Lor.S3.Api.delete_object(bucket, key)
    error_result
  end

  defp handle_after_transaction(_changeset, success_or_error_result) do
    success_or_error_result
  end
end
