defmodule Lor.Lol.Replay do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Lor.Lol,
    extensions: [
      AshStateMachine
    ]

  postgres do
    table "lol_replays"

    repo Lor.Repo

    migration_types first_chunk_id: :smallint,
                    first_key_frame_id: :smallint,
                    last_chunk_id: :smallint,
                    last_key_frame_id: :smallint
  end

  identities do
    identity :game_id, [:game_id, :platform_id]
  end

  code_interface do
    domain Lor.Lol
    define :read_all, action: :read
    define :create
    define :finish, action: :finish
    define :error, action: :error
    define :update_with_match, action: :update_with_match, args: [:match_id]

    define :get_by_id, action: :by_id, args: [:id]

    define :get_by_game_id_and_platform_id,
      action: :by_game_id_and_platform_id,
      args: [:platform_id, :game_id]

    define :get_by_game_version, action: :get_by_game_version, args: [:game_version]
    define :get_by_state, action: :get_by_state, args: [:state]
    define :list_game_version
    define :destroy
  end

  actions do
    defaults [:read]

    create :create do
      accept [
        :game_meta_data,
        :game_id,
        :platform_id,
        :encryption_key,
        :first_chunk_id,
        :first_key_frame_id,
        :last_chunk_id,
        :last_key_frame_id
      ]
    end

    read :by_id do
      get? true

      argument :id, :uuid, allow_nil?: false

      filter expr(id == ^arg(:id))
    end

    read :by_game_id_and_platform_id do
      get? true

      argument :platform_id, Lor.Lol.PlatformIds, allow_nil?: false
      argument :game_id, :integer, allow_nil?: false

      prepare Lor.Lol.Replay.Preparations.FilterByGameIdAndPlatformId
    end

    read :get_by_game_version do
      get? true

      argument :game_version, :string, allow_nil?: false

      prepare Lor.Lol.Replay.Preparations.FilterByGameVersion
    end

    read :get_by_state do
      get? true

      argument :state, :string, allow_nil?: false

      prepare Lor.Lol.Replay.Preparations.FilterByState
    end

    action :list_game_version, {:array, :string} do
      run Lor.Lol.Replay.Actions.ListGameVersions
    end

    update :finish do
      accept [:first_chunk_id, :last_chunk_id, :first_key_frame_id, :last_key_frame_id]
      require_atomic? false

      change transition_state(:finished)
      change Lor.Lol.Replay.Changes.CreateMatchJob
    end

    update :error do
      change transition_state(:errored)
    end

    update :update_with_match do
      require_atomic? false
      argument :match_id, :uuid, allow_nil?: false
      change manage_relationship(:match_id, :match, type: :append)
    end

    destroy :destroy do
      require_atomic? false
      primary? true

      change Lor.Lol.Replay.Changes.Destroy
    end
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

    attribute :first_chunk_id, :integer do
      description "Chunk availability starts at 3; chunks 1 and 2 is always available."
    end

    attribute :first_key_frame_id, :integer
    attribute :last_chunk_id, :integer
    attribute :last_key_frame_id, :integer

    attribute :state, :atom do
      allow_nil? false
      default :recording
      constraints one_of: [:recording, :finished, :errored]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  state_machine do
    initial_states([:recording])
    default_initial_state(:recording)

    transitions do
      transition(:finish, from: :recording, to: :finished)
      transition(:error, from: :recording, to: :errored)
    end
  end

  calculations do
    calculate :complete, :boolean, expr(first_chunk_id == 3 and first_key_frame_id == 1)
  end

  relationships do
    has_many :key_frames, Lor.Lol.KeyFrame
    has_many :chunks, Lor.Lol.Chunk

    belongs_to :match, Lor.Lol.Match do
      attribute_type :uuid
      allow_nil? true
      attribute_writable? true
    end
  end
end
