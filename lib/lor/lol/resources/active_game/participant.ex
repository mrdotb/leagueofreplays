defmodule Lor.Lol.ActiveGame.Participant do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :name, :string
    attribute :puuid, :string
    attribute :summoners, {:array, :integer}
    attribute :team_id, :integer
    attribute :champion_id, :integer
  end

  calculations do
    calculate :summoner, :struct, Lor.Lol.ActiveGame.Calculations.LoadSummoner
  end
end
