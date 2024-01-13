defmodule Lor.Lol.ActiveGameTest do
  use Lor.DataCase, async: true

  test "active game simple" do
    active_game_data = Lor.DataFixtures.active_game()

    player =
      Lor.Pros.Player.create_from_ugg!(
        %{
          "normalized_name" => "coolran",
          "official_name" => "Coolran",
          "main_role" => "top"
        },
        nil,
        nil
      )

    coolran_data = List.first(active_game_data["participants"])

    summoner_data = %{
      "name" => "coolran",
      "accountId" => "123",
      "id" => "123",
      "puuid" => coolran_data["puuid"],
      "profileIconId" => 4653,
      "revisionDate" => 1_649_191_473_000,
      "summonerLevel" => 287
    }

    account_data = %{
      "gameName" => "coolran",
      "tagLine" => "#KR1"
    }

    Lor.Lol.Summoner.create_from_api!(:kr, summoner_data, account_data, player.id)

    active_game = Lor.Lol.ActiveGame.create_from_api!(active_game_data)
    active_game = Lor.Lol.load!(active_game, [:pro_participants])
    assert [{_pro_summoner, _participant}] = active_game.pro_participants
  end
end
