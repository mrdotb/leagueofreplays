defmodule Lor.Lol.Match do
  @moduledoc """
  This model aggregate match metadata and info
  https://developer.riotgames.com/apis#match-v5/GET_getMatch
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lol_matches"

    repo Lor.Repo
  end

  identities do
    identity :game_id, [:game_id]
    identity :match_id, [:match_id]
  end

  code_interface do
    define_for Lor.Lol
    define :read_all, action: :read
    define :get, action: :by_id, args: [:id]
    define :create_from_api, args: [:match_data, :s3_object_id]
  end

  actions do
    defaults [:read]

    read :by_id do
      get? true
      argument :id, :uuid, allow_nil?: false

      filter expr(id == ^arg(:id))
    end

    create :create_from_api do
      accept []

      argument :match_data, :map do
        allow_nil? false
      end

      argument :s3_object_id, :uuid do
        allow_nil? false
      end

      change Lor.Lol.Match.Changes.CreateFromApi
    end
  end

  attributes do
    uuid_primary_key :id

    # Metadata
    attribute :data_version, :string do
      allow_nil? false
      description "Match data version"
    end

    attribute :game_id, :integer, allow_nil?: false
    attribute :platform_id, Lor.Lol.PlatformIds, allow_nil?: false

    attribute :match_id, :string do
      allow_nil? false
      description "platform_id + game_id ex: KR_6821747606"
    end

    attribute :participant_puuids, {:array, :string} do
      allow_nil? false
      description "List of participants PUUIDs. Original name `participants`."
    end

    # Info
    attribute :game_creation, :integer do
      allow_nil? false
      description "When the game is created (loading screen)."
    end

    attribute :game_duration, :integer do
      allow_nil? false

      description "Game length in milliseconds calculated from gameEndTimestamp - gameStartTimestamp"
    end

    attribute :game_start_timestamp, :integer do
      allow_nil? false
      description "Unix timestamp for when match starts on the game server."
    end

    attribute :game_end_timestamp, :integer do
      allow_nil? false
      description "Unix timestamp for when match ends on the game server."
    end

    attribute :game_start, :datetime do
      allow_nil? false
      description "Unix timestamp converted to date type"
    end

    attribute :game_version, :string, allow_nil?: false

    attribute :assets_version, :string do
      allow_nil? false
      description "Game version converted to asset version. ex: 13.24.547.9214 -> 13.24.1"
    end

    attribute :game_mode, Lor.Lol.GameModes, allow_nil?: false
    attribute :game_name, :string, allow_nil?: false
    attribute :game_type, :string, allow_nil?: false
    attribute :map_id, :integer, allow_nil?: false
    attribute :queue_id, :integer, allow_nil?: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :participants, Lor.Lol.Participant

    belongs_to :original_data, Lor.S3.Object do
      api Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end

    has_one :replay, Lor.Lol.Replay
  end
end
