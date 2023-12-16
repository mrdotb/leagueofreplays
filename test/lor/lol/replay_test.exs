defmodule Lor.Lol.ReplayTest do
  use Lor.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  test "create a replay from api" do
    use_cassette "leagueofgraph" do
      log_client = Lor.Lol.Observer.Client.new("http://replays.leagueofgraphs.com:80")

      {:ok, game_meta_data} =
        Lor.Lol.Observer.Client.fetch_game_meta_data(log_client, "EUW1-12345689", "6720928471")

      params = %{
        platform_id: :euw1,
        game_id: "6720928471",
        game_meta_data: game_meta_data,
        encryption_key: "lmmwcqeQfVEGpRtMHLd5634xeIlAtpL4"
      }

      {:ok, replay} = Lor.Lol.Replay.create(params)

      assert is_map(replay.game_meta_data)
      assert replay.platform_id == :euw1
    end
  end
end
