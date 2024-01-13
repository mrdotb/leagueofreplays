defmodule Lor.DataFixtures do
  def active_game do
    %{
      "bannedChampions" => [
        %{"championId" => 110, "pickTurn" => 1, "teamId" => 100},
        %{"championId" => 238, "pickTurn" => 2, "teamId" => 100},
        %{"championId" => 22, "pickTurn" => 3, "teamId" => 100},
        %{"championId" => 30, "pickTurn" => 4, "teamId" => 100},
        %{"championId" => 68, "pickTurn" => 5, "teamId" => 100},
        %{"championId" => 236, "pickTurn" => 6, "teamId" => 200},
        %{"championId" => 235, "pickTurn" => 7, "teamId" => 200},
        %{"championId" => 7, "pickTurn" => 8, "teamId" => 200},
        %{"championId" => -1, "pickTurn" => 9, "teamId" => 200},
        %{"championId" => 35, "pickTurn" => 10, "teamId" => 200}
      ],
      "gameId" => 6_900_369_560,
      "gameLength" => 163,
      "gameMode" => "CLASSIC",
      "gameQueueConfigId" => 420,
      "gameStartTime" => 1_705_151_852_647,
      "gameType" => "MATCHED",
      "mapId" => 11,
      "observers" => %{"encryptionKey" => "opzBgSEXG3liv/SWLj6joYshKnfea9E6"},
      "participants" => [
        %{
          "bot" => false,
          "championId" => 268,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8021, 8009, 9104, 8014, 8226, 8233, 5005, 5008, 5001],
            "perkStyle" => 8000,
            "perkSubStyle" => 8200
          },
          "profileIconId" => 4903,
          "puuid" =>
            "hskY-agsqCEDDs6e8HAteBDXemMr20uyDM-dVil5Ad-TgcpO4ffUW3ZZfkckMbQ_YAq6iRuwFXnrXw",
          "spell1Id" => 4,
          "spell2Id" => 12,
          "summonerId" => "5DtRicXJQf0VgrIl43LNvh837QEZBgDk3rK_iodK6mFkJg",
          "summonerName" => "coolran",
          "teamId" => 100
        },
        %{
          "bot" => false,
          "championId" => 24,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8437, 8446, 8444, 8242, 8345, 8347, 5005, 5008, 5002],
            "perkStyle" => 8400,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 3582,
          "puuid" =>
            "hKdy7_DCaj7FcZglqnLWslgD7uRW2tl5pJ8kZlWd47Pj9G_bnj-CRwaAm1oD67r1jW54gr9u7-ayMA",
          "spell1Id" => 12,
          "spell2Id" => 4,
          "summonerId" => "n3vJTJ6duon2pvqwOcwVnQw3Zh0rIynBVw_WRefR7q7dGr8",
          "summonerName" => "죽림초",
          "teamId" => 100
        },
        %{
          "bot" => false,
          "championId" => 429,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [9923, 8143, 8138, 8135, 8345, 8347, 5005, 5008, 5002],
            "perkStyle" => 8100,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 22,
          "puuid" =>
            "HW1IB5S4Zzfg0DZ-3KrwhGPjDv0HuoAot61KVBxSVOgWsGkjo2hGKBL6vBm8c5sAoK0iyLtAaYTSgA",
          "spell1Id" => 3,
          "spell2Id" => 4,
          "summonerId" => "d2mO8MKB-a8yvq57kgxYUn6uY1E-4GfHoiNR-B1IuKVW_Vilo4whXAvTHw",
          "summonerName" => "Moonlight505",
          "teamId" => 100
        },
        %{
          "bot" => false,
          "championId" => 51,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [9923, 8139, 8136, 8106, 8345, 8347, 5005, 5008, 5002],
            "perkStyle" => 8100,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 7,
          "puuid" =>
            "Ohr19bdYO-_YTTQMLBkGV9NZ86mnP4IQHLwt6AarIxwiW-TXpEmiflNTfKHYsOhZDvo5z7IQlEWRaQ",
          "spell1Id" => 4,
          "spell2Id" => 7,
          "summonerId" => "85OpSh79kxhAmIxrKk8qkFa7Si6yTF9pV0cZ_OcE6FL4JNP3",
          "summonerName" => "godeppin",
          "teamId" => 100
        },
        %{
          "bot" => false,
          "championId" => 104,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8021, 9111, 9104, 8014, 8304, 8347, 5005, 5008, 5002],
            "perkStyle" => 8000,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 5626,
          "puuid" =>
            "l0WnGkkZ7m1m3vFoypGuToHG09bKpK5X__D0yQgaf7koZHGLcdjUdOjNlnxRqeTvdf51rG3aFCIJHQ",
          "spell1Id" => 11,
          "spell2Id" => 4,
          "summonerId" => "liOVuw2VYa3ZxH2DkzGxEsoEIt1bkJ9mu7rwnsYDYRfzYMcg7d7ViZSJBw",
          "summonerName" => "손주녁",
          "teamId" => 100
        },
        %{
          "bot" => false,
          "championId" => 64,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8010, 9111, 9104, 8014, 8347, 8304, 5005, 5008, 5002],
            "perkStyle" => 8000,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 3495,
          "puuid" =>
            "yOPbuXEHeUUXYf8yKFxg3myObZop5xRuq1I8Ku_0nIWJFRkp_UagOZ6bc1qc3WRvYCERj7vvKUvm9g",
          "spell1Id" => 11,
          "spell2Id" => 4,
          "summonerId" => "D_RCYDPbdOnY6wUuAn9YOr3FRGZ26j6I810fiY6lwEopUW38",
          "summonerName" => "나는 멍청이 우우",
          "teamId" => 200
        },
        %{
          "bot" => false,
          "championId" => 3,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8112, 8143, 8138, 8105, 8275, 8237, 5008, 5008, 5003],
            "perkStyle" => 8100,
            "perkSubStyle" => 8200
          },
          "profileIconId" => 7,
          "puuid" =>
            "0MFEP4EcPQuQTB4GJISFSl8gbIZkDqRgmApfROUDRvm_C-9z0wLns2jSHC4TAHFwc6VGEdGzEjImkA",
          "spell1Id" => 6,
          "spell2Id" => 4,
          "summonerId" => "rmX9IsMriQR8O_IIvu35gFT3pEiWh7qMwk1J60KfhW8FCz9gKprYxt6tSQ",
          "summonerName" => "ChuJunz",
          "teamId" => 200
        },
        %{
          "bot" => false,
          "championId" => 126,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8010, 8009, 9104, 8299, 8304, 8345, 5008, 5008, 5002],
            "perkStyle" => 8000,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 5,
          "puuid" =>
            "UekmjboOXrg6GO53YTj-TVtLw-BcjQ1GFMPFcoMyRUPGxFte3-lap9p_O4H0uQu9EQEbM9YGYZ6OHw",
          "spell1Id" => 12,
          "spell2Id" => 4,
          "summonerId" => "ohM584arkjVmfLGrsRjm9gSPUyRheKGZV7cis5l_OrY2db6oqxLMHS5Z5Q",
          "summonerName" => "Want To Be Young",
          "teamId" => 200
        },
        %{
          "bot" => false,
          "championId" => 119,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [8005, 8009, 9103, 8014, 8345, 8313, 5005, 5008, 5002],
            "perkStyle" => 8000,
            "perkSubStyle" => 8300
          },
          "profileIconId" => 23,
          "puuid" =>
            "dFk1yXYASh8nMkfmcUbQzcYy03yhFKVS7abYlMNiIAtRXH9cWTYhjT3TORvq56clhT4ix-paSf8KTw",
          "spell1Id" => 7,
          "spell2Id" => 4,
          "summonerId" => "nGMd7cIKib7yVK-MQvazk0JjOHP0RNGraBMD1b0ehl7UBDz7Y95mRh6_5Q",
          "summonerName" => "LSB Diable",
          "teamId" => 200
        },
        %{
          "bot" => false,
          "championId" => 555,
          "gameCustomizationObjects" => [],
          "perks" => %{
            "perkIds" => [9923, 8126, 8136, 8135, 8275, 8210, 5008, 5008, 5002],
            "perkStyle" => 8100,
            "perkSubStyle" => 8200
          },
          "profileIconId" => 6330,
          "puuid" =>
            "GRSGyiuNLZMtzihQn7AoWgWGRumU2SLEZ1qhFo7pKH852cCJyKMHpsdh4JHohgmu87JRGy91VIG9hg",
          "spell1Id" => 14,
          "spell2Id" => 4,
          "summonerId" => "mcLNWShqq8zuqfJz2DyQrt1GP-2S0w0h7U-6gFLkO58gl7_bEXeaWtgWSA",
          "summonerName" => "노장 두티",
          "teamId" => 200
        }
      ],
      "platformId" => "KR"
    }
  end
end
