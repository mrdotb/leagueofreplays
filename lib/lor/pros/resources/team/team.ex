defmodule Lor.Pros.Team do
  @moduledoc """
  This model represent a pro team like 'SKT', 'Cloud9' ...
  It's based on the UGG schema
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Lor.Pros

  postgres do
    table "pro_teams"

    repo Lor.Repo

    migration_types name: :citext

    references do
      reference :logo, on_delete: :nothing
    end
  end

  identities do
    identity :name, [:name]
  end

  code_interface do
    domain Lor.Pros
    define :get, action: :get, args: [:id]
    define :create_from_ugg, args: [:team_data, :logo_id]
    define :by_names, args: [:names]
    define :list, action: :list, args: [:filter]
    define :destroy
  end

  actions do
    defaults [:read]

    read :get do
      get? true
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
    end

    read :by_names do
      argument :names, {:array, :string} do
        allow_nil? false
      end

      filter expr(name in ^arg(:names))
    end

    read :list do
      argument :filter, :map, allow_nil?: true

      pagination do
        offset? true
        countable :by_default
        max_page_size 20
      end

      prepare Lor.Pros.Team.Preparations.FilterSortTeam
    end

    create :create do
      primary? true
      accept [:name, :short_name]

      argument :logo_id, :uuid do
        allow_nil? true
      end

      change manage_relationship(:logo_id, :logo, type: :append)
    end

    create :create_from_ugg do
      accept []

      argument :team_data, :map do
        allow_nil? false
      end

      argument :logo_id, :uuid

      change Lor.Pros.Team.Changes.CreateFromUGG
    end

    update :update do
      primary? true
      require_atomic? false

      accept [:name, :short_name]

      argument :logo_id, :uuid do
        allow_nil? true
      end

      change manage_relationship(:logo_id, :logo, type: :append_and_remove)
      change Lor.Pros.Team.Changes.Update
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      change Lor.Pros.Team.Changes.Destroy
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :short_name, :string
    attribute :liquidpedia_url, :string

    # attribute :league, :atom do
    #   allow_nil? false
    #   constraints [one_of: ~w(LJL TCL CBLOL LCS LCO VCS LCK LCL LLA LPL LEC)a]
    # end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :players_count, :integer, expr(count(players))
  end

  relationships do
    has_many :players, Lor.Pros.Player do
      destination_attribute :current_team_id
    end

    belongs_to :logo, Lor.S3.Object do
      domain Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end
  end
end
