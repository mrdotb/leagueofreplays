defmodule Lor.Lol.MatchReactorTest do
  use Lor.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

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

  test "already exist" do
    use_cassette "faker_ranked_match" do
      {:ok, _result} =
        Reactor.run(
          Lor.Lol.MatchReactor,
          %{region: :ASIA, platform_id: :kr, match_id: "KR_6821747606"}
        )

      {:error, [%{errors: _errors}]} =
        Reactor.run(
          Lor.Lol.MatchReactor,
          %{region: :ASIA, platform_id: :kr, match_id: "KR_6821747606"}
        )
    end
  end
end
