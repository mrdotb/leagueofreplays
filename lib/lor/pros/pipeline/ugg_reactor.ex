defmodule Lor.Pros.UGGReactor do
  @moduledoc """
  Pipeline to collect and create the team
  """
  use Reactor

  input(:platform_id)

  step :fetch_ugg_pros, Lor.Pros.FetchUGGProsStep do
    argument :platform_id, input(:platform_id)
  end

  step :fetch_teams, Lor.Pros.FetchTeamsStep do
    argument :ugg_pros, result(:fetch_ugg_pros)
  end

  step :fetch_players, Lor.Pros.FetchPlayersStep do
    argument :ugg_pros, result(:fetch_ugg_pros)
  end

  step :create_teams, Lor.Pros.CreateTeamsStep do
    argument :teams_to_create do
      source result(:fetch_teams)
      transform(& &1.teams_to_create)
    end
  end

  step :create_players, Lor.Pros.CreatePlayersStep do
    argument :players_to_create do
      source result(:fetch_players)
      transform(& &1.players_to_create)
    end

    argument :existing_teams do
      source result(:fetch_teams)
      transform(& &1.existing_teams)
    end

    argument :created_teams, result(:create_teams)
  end

  step :create_summoners, Lor.Pros.CreateSummonersStep do
    argument :platform_id, input(:platform_id)
    argument :ugg_pros, result(:fetch_ugg_pros)
    argument :created_players, result(:create_players)

    argument :existing_players do
      source result(:fetch_players)
      transform(& &1.existing_players)
    end
  end
end
