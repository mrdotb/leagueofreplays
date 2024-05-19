defmodule Lor.Lol.ActiveGame do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    domain: Lor.Lol

  import Ecto.Query

  postgres do
    table "lol_active_games"

    repo Lor.Repo
  end

  pub_sub do
    module LorWeb.Endpoint
    prefix "active_game"

    publish :create_from_api, "created"
    publish :destroy, "destroyed"
  end

  code_interface do
    domain Lor.Lol
    define :get, action: :by_id, args: [:id]
    define :list, action: :list, args: [:filter]
    define :list_active_puuids, action: :list_active_puuids, args: [:platform_id]
    define :create_from_api, args: [:active_game]
    define :destroy
  end

  actions do
    defaults [:read, :destroy]

    read :by_id do
      get? true
      argument :id, :string, allow_nil?: false

      filter expr(id == ^arg(:id))
    end

    read :list do
      argument :filter, :map, allow_nil?: true

      prepare Lor.Lol.ActiveGame.Preparations.FilterSort
    end

    action :list_active_puuids, :map do
      argument :platform_id, Lor.Lol.PlatformIds do
        allow_nil? false
      end

      run fn input, _context ->
        query =
          from active_game in Lor.Lol.ActiveGame,
            where: active_game.platform_id == ^input.arguments.platform_id,
            select: fragment("UNNEST(participants)->>'puuid'")

        {:ok, Lor.Repo.all(query)}
      end
    end

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
    attribute :platform_id, Lor.Lol.PlatformIds, allow_nil?: false
    attribute :game_mode, :string, allow_nil?: false
    attribute :game_start_time, :datetime, allow_nil?: false
    attribute :game_id, :integer, allow_nil?: false

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
