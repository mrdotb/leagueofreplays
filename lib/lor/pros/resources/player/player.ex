defmodule Lor.Pros.Player do
  @moduledoc """
  This model reprensent a pro player or a streamer like 'Faker', 'Tyler1'
  It's based on the UGG schema
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pro_players"
    repo Lor.Repo

    migration_types normalized_name: :citext
  end

  identities do
    identity :normalized_name, [:normalized_name]
    identity :official_name, [:official_name]
  end

  code_interface do
    define_for Lor.Pros

    define :create_from_ugg, args: [:player_data, :current_team_id, :picture_id]
    define :by_normalized_names, args: [:normalized_names]
  end

  actions do
    defaults [:read]

    read :by_normalized_names do
      argument :normalized_names, {:array, :string} do
        allow_nil? false
      end

      filter expr(normalized_name in ^arg(:normalized_names))
    end

    create :create_from_ugg do
      accept []

      argument :player_data, :map do
        allow_nil? false
      end

      argument :current_team_id, :uuid
      argument :picture_id, :uuid

      change Lor.Pros.Player.Changes.CreateFromUGG
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :normalized_name, :string, allow_nil?: false
    attribute :official_name, :string, allow_nil?: false
    attribute :liquidpedia_url, :string
    attribute :main_role, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :current_team, Lor.Pros.Team do
      attribute_type :uuid
      attribute_writable? true
    end

    belongs_to :picture, Lor.S3.Object do
      api Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end

    has_many :summoners, Lor.Lol.Summoner do
      api Lor.Lol
    end
  end
end
