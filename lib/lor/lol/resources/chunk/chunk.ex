defmodule Lor.Lol.Chunk do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Lor.Lol

  postgres do
    table "lol_replay_chunks"

    repo Lor.Repo

    migration_types number: :smallint

    references do
      reference :replay, on_delete: :delete
      reference :data, on_delete: :delete
    end
  end

  identities do
    identity :unique_chunk_number_per_replay, [:number, :replay_id]
  end

  code_interface do
    domain Lor.Lol
    define :read_all, action: :read
    define :create
  end

  actions do
    defaults [:read]

    create :create do
      accept [
        :number,
        :replay_id,
        :data_id
      ]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :number, :integer, allow_nil?: false
  end

  relationships do
    belongs_to :replay, Lor.Lol.Replay do
      attribute_type :uuid
      attribute_writable? true
    end

    belongs_to :data, Lor.S3.Object do
      domain Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end
  end
end
