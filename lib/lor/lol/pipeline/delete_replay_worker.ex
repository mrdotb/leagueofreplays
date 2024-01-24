defmodule Lor.Lol.DeleteReplayWorker do
  @moduledoc """
  A recursive job to delete replay from specific patch.
  """
  use Oban.Worker

  @backfill_delay 1

  @impl true
  def perform(%{args: %{"game_version" => game_version}}) do
    case Lor.Lol.Replay.get_by_game_version(game_version) do
      {:ok, replay} ->
        Lor.Lol.Replay.destroy!(replay)

        %{game_version: game_version}
        |> new(schedule_in: @backfill_delay)
        |> Oban.insert()

      {:error, _not_found} ->
        :ok
    end
  end
end
