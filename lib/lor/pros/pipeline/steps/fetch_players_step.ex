defmodule Lor.Pros.FetchPlayersStep do
  @moduledoc """
  Fetch existing_players from the database and compare what we should create from
  UGG
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    ugg_pros = arguments.ugg_pros
    players = Enum.uniq_by(ugg_pros, & &1["normalized_name"])

    normalized_names = Enum.map(players, & &1["normalized_name"])
    existing_players = Lor.Pros.Player.by_normalized_names!(normalized_names)

    existing_player_normalized_names_set =
      existing_players
      |> Enum.map(& &1.normalized_name)
      |> MapSet.new()

    players_to_create =
      Enum.reject(
        players,
        &MapSet.member?(existing_player_normalized_names_set, &1["normalized_name"])
      )

    result = %{
      existing_players: existing_players,
      players_to_create: players_to_create
    }

    {:ok, result}
  end
end
