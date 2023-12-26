defmodule Lor.Lol.Replay.Changes.CreateMatchJob do
  @moduledoc """
  Create the match job
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    Ash.Changeset.after_transaction(changeset, &handle_after_transaction/2)
  end

  defp handle_after_transaction(_changeset, {:error, _} = error_result) do
    error_result
  end

  defp handle_after_transaction(_changeset, {:ok, replay} = success_result) do
    %{replay_id: replay.id}
    |> Lor.Lol.MatchWorker.new()
    |> Oban.insert()

    success_result
  end
end
