defmodule Lor.Pros.UGGReactorTest do
  use Lor.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  test "successfull" do
    use_cassette "ugg_riot_br1" do
      {:ok, _result} =
        Reactor.run(
          Lor.Pros.UGGReactor,
          %{platform_id: :br1}
        )
    end
  end
end
