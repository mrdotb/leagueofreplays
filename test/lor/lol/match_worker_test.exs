defmodule Lor.Lol.MatchWorkerTest do
  use Lor.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "job will set a foreign key on replay to the created match" do
    use_cassette "faker_ranked_match" do
      replay =
        Lor.Lol.Replay.create!(%{
          platform_id: :kr,
          game_id: "6821747606",
          game_meta_data: %{},
          encryption_key: "lmmwcqeQfVEGpRtMHLd5634xeIlAtpL4"
        })

      {:ok, replay} = perform_job(Lor.Lol.MatchWorker, %{replay_id: replay.id})
      assert is_binary(replay.match_id)
    end
  end
end
