defmodule Lor.Lol.ActiveGame.Calculations.LoadProParticipants do
  use Ash.Resource.Calculation
  require Ash.Query

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def load(_query, _opts, _context) do
    []
  end

  @impl true
  def calculate(active_games, _opts, _) do
    puuids =
      Enum.flat_map(active_games, fn active_game ->
        Enum.map(active_game.participants, fn participant ->
          participant.puuid
        end)
      end)

    pro_summoners_map =
      Lor.Lol.Summoner
      |> Ash.Query.for_read(:by_puuids, %{puuids: puuids})
      |> Ash.Query.load(
        player: [
          :picture,
          current_team: :logo
        ]
      )
      |> Ash.Query.filter(not is_nil(player))
      |> Ash.read!()
      |> Map.new(fn summoner -> {summoner.puuid, summoner} end)

    calculates =
      Enum.map(active_games, fn active_game ->
        Enum.reduce(active_game.participants, [], fn participant, acc ->
          case Map.fetch(pro_summoners_map, participant.puuid) do
            {:ok, pro_summoner} ->
              [{pro_summoner, participant} | acc]

            :error ->
              acc
          end
        end)
      end)

    {:ok, calculates}
  end
end
