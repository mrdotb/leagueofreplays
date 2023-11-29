defmodule Lor.Lol.MatchReactorTest do
  use Lor.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  test "successfull" do
    use_cassette "faker_ranked_match" do
      {:ok, result} =
        Reactor.run(
          Lor.Lol.MatchReactor,
          %{region: :ASIA, platform_id: :kr, match_id: "KR_6821747606"}
        )

      assert result.valid?
      assert result.complete?
    end
  end
end
