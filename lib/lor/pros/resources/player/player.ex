defmodule Lor.Pros.Player do
  @moduledoc """
  This model reprensent a pro player or a streamer like 'Faker', 'Tyler1'
  It's based on the UGG schema
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Lor.Pros

  postgres do
    table "pro_players"
    repo Lor.Repo

    migration_types normalized_name: :citext

    references do
      reference :current_team, on_delete: :nilify
      reference :picture, on_delete: :delete
    end
  end

  identities do
    identity :normalized_name, [:normalized_name]
    identity :official_name, [:official_name]
  end

  code_interface do
    domain Lor.Pros
    define :get, action: :get, args: [:id]
    define :by_normalized_name, args: [:normalized_name]
    define :by_normalized_names, args: [:normalized_names]
    define :list, action: :list, args: [:filter]
    define :create_from_ugg, args: [:player_data, :current_team_id, :picture_id]
  end

  actions do
    defaults [:read]

    read :get do
      get? true
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
    end

    read :by_normalized_name do
      get? true

      argument :normalized_name, :string do
        allow_nil? false
      end

      filter expr(normalized_name == ^arg(:normalized_name))
    end

    read :by_normalized_names do
      argument :normalized_names, {:array, :string} do
        allow_nil? false
      end

      filter expr(normalized_name in ^arg(:normalized_names))
    end

    read :list do
      argument :filter, :map, allow_nil?: true

      pagination do
        offset? true
        countable :by_default
        max_page_size 20
      end

      prepare Lor.Pros.Player.Preparations.FilterSortPlayer
    end

    create :create do
      primary? true
      accept [:official_name, :record, :liquidpedia_url, :main_role]

      argument :current_team_id, :uuid do
        allow_nil? true
      end

      argument :picture_id, :uuid do
        allow_nil? true
      end

      change manage_relationship(:current_team_id, :current_team, type: :append)
      change manage_relationship(:picture_id, :picture, type: :append)
      change Lor.Pros.Player.Changes.NormalizeName
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

    update :update do
      primary? true
      require_atomic? false

      accept [:official_name, :record, :liquidpedia_url, :main_role]

      argument :current_team_id, :uuid do
        allow_nil? true
      end

      argument :picture_id, :uuid do
        allow_nil? true
      end

      change manage_relationship(:current_team_id, :current_team, type: :append_and_remove)
      change manage_relationship(:picture_id, :picture, type: :append_and_remove)
      change Lor.Pros.Player.Changes.NormalizeName
      change Lor.Pros.Player.Changes.Update
    end

    destroy :destroy do
      require_atomic? false
      primary? true

      change Lor.Pros.Player.Changes.Destroy
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :normalized_name, :string, allow_nil?: false
    attribute :official_name, :string, allow_nil?: false
    attribute :liquidpedia_url, :string
    attribute :main_role, :string
    attribute :record, :boolean, allow_nil?: false, default: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :current_team_name, :string, expr(current_team.name)
  end

  relationships do
    belongs_to :current_team, Lor.Pros.Team do
      attribute_type :uuid
      public? true
      attribute_writable? true
    end

    belongs_to :picture, Lor.S3.Object do
      domain Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end

    has_many :summoners, Lor.Lol.Summoner do
      domain Lor.Lol
    end
  end
end
