defmodule Lor.Lol.Replay do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lol_replays"

    repo Lor.Repo

    migration_defaults(status: "\"recording\"")
  end

  identities do
    identity :game_id, [:game_id, :platform_id]
  end

  code_interface do
    define_for Lor.Lol
    define :read_all, action: :read
    define :create
  end

  actions do
    defaults [:read, :create]
  end

  attributes do
    uuid_primary_key :id

    attribute :game_meta_data, :map, allow_nil?: false

    attribute :game_id, :integer, allow_nil?: false
    attribute :platform_id, Lor.Lol.PlatformIds, allow_nil?: false

    attribute :encryption_key, :string do
      allow_nil? false
      description "Key used to decrypt the spectator grid game data for playback"
    end

    attribute :status, :atom do
      allow_nil? false
      default :recording
      constraints one_of: [:recording, :finished, :errored]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :key_frames, Lor.Lol.KeyFrame
    has_many :chunks, Lor.Lol.Chunk
  end
end
