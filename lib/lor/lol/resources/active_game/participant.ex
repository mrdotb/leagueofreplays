defmodule Lor.Lol.ActiveGame.Participant do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :name, :string, public?: true
    attribute :puuid, :string, public?: true
    attribute :summoners, {:array, :integer}, public?: true
    attribute :team_id, :integer, public?: true
    attribute :champion_id, :integer, public?: true
  end
end
