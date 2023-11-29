defmodule Lor.Lol.Summoner do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lol_summoners"

    repo Lor.Repo
  end

  identities do
    identity :riot_id, [:riot_id]
    identity :encrypted_id, [:encrypted_id]
    identity :puuid, [:puuid]
    identity :account_id, [:account_id]
  end

  code_interface do
    define_for Lor.Lol
    define :create_from_api, args: [:platform_id, :summoner_data, :account_data]
    define :read_all, action: :read

    define :by_puuids, args: [:puuids]
  end

  actions do
    defaults [:read]

    read :by_puuids do
      argument :puuids, {:array, :string} do
        allow_nil? false
      end

      filter expr(puuid in ^arg(:puuids))
    end

    create :create_from_api do
      accept [:platform_id]

      argument :summoner_data, :map do
        allow_nil? false
      end

      argument :account_data, :map do
        allow_nil? false
      end

      change Lor.Lol.Summoner.Changes.CreateFromApi
    end
  end

  attributes do
    uuid_primary_key :id

    # Added fields

    attribute :platform_id, Lor.Lol.PlatformIds do
      allow_nil? false
      description "The routing platform"
    end

    attribute :riot_id, :string do
      allow_nil? false
      description "New riot id ex: abc#abc"
    end

    # Original fields

    attribute :account_id, :string do
      allow_nil? false
      description "Encrypted account ID. Max length 56 characters."
    end

    attribute :encrypted_id, :string do
      allow_nil? false
      description "Original name `id`. Encrypted summoner ID. Max length 63 characters."
    end

    attribute :puuid, :string do
      allow_nil? false
      description "Encrypted PUUID. Exact length of 78 characters."
    end

    attribute :profile_icon_id, :integer do
      allow_nil? false
      description "ID of the summoner icon associated with the summoner."
    end

    attribute :revision_date, :integer do
      allow_nil? false

      description "Date summoner was last modified specified as epoch milliseconds. The following events will update this timestamp: profile icon change, playing the tutorial or advanced tutorial, finishing a game, summoner name change"
    end

    attribute :name, :string do
      allow_nil? false
      description "Current name of the summoner"
    end

    attribute :summoner_level, :integer do
      allow_nil? false
      description "Summoner level associated with the summoner."
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
