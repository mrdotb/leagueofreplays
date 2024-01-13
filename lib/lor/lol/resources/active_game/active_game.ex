defmodule Lor.Lol.ActiveGame do
  use Ash.Resource

  # use Ash.Resource,
  #   data_layer: Ash.DataLayer.Ets

  code_interface do
    define_for Lor.Lol
    define :create_from_api, args: [:active_game]
  end

  actions do
    defaults [:read]

    create :create_from_api do
      accept []

      argument :active_game, :map do
        allow_nil? false
      end

      change Lor.Lol.ActiveGame.Changes.CreateFromApi
    end
  end

  attributes do
    attribute :id, :string, primary_key?: true, allow_nil?: false
    attribute :platform_id, Lor.Lol.PlatformIds
    attribute :game_mode, :string
    attribute :game_start_time, :datetime

    attribute :encryption_key, :string do
      allow_nil? false
      description "Key used to decrypt the spectator grid game data for playback"
    end

    attribute :participants, {:array, Lor.Lol.ActiveGame.Participant}
  end

  calculations do
    calculate :pro_participants,
              {:array, :struct},
              Lor.Lol.ActiveGame.Calculations.LoadProParticipants
  end
end
