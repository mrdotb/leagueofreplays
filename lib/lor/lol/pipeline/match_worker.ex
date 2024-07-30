defmodule Lor.Lol.MatchWorker do
  use Oban.Worker

  require Logger

  @impl true
  def perform(%{args: %{"replay_id" => replay_id}}) do
    replay = Lor.Lol.Replay.get_by_id!(replay_id)
    platform_id = replay.platform_id
    region_account = Lor.Lol.PlatformIds.fetch_region!(platform_id, :account)
    region_match = Lor.Lol.PlatformIds.fetch_region!(platform_id, :match)
    match_id = Lor.Lol.Helpers.get_match_id(platform_id, replay.game_id)

    args = %{
      region_account: region_account,
      region_match: region_match,
      platform_id: platform_id,
      match_id: match_id
    }

    Logger.debug(inspect(args))

    case Reactor.run(Lor.Lol.MatchReactor, args) do
      {:ok, result} ->
        match = result.create_match
        Lor.Lol.Replay.update_with_match(replay, match.id)

      # reactor error are too heavy pattern match only the ash errors
      {:error, [%{errors: errors}]} ->
        {:error, errors}

      error ->
        error
    end
  end
end
