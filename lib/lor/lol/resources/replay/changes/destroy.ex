defmodule Lor.Lol.Replay.Changes.Destroy do
  @moduledoc """
  Handle the destroy of a replay
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.before_transaction(changeset, &handle_before_transaction/1)
  end

  # Try to destroy s3 chunks before deleting the replays
  defp handle_before_transaction(changeset) do
    for chunk <- changeset.data.chunks do
      Lor.S3.Object.destroy(chunk.data)
    end

    for key_frame <- changeset.data.key_frames do
      Lor.S3.Object.destroy(key_frame.data)
    end

    changeset
  end
end
