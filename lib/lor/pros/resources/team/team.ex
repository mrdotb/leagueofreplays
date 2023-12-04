defmodule Lor.Pros.Team do
  @moduledoc """
  This model represent a pro team like 'SKT', 'Cloud9' ...
  It's based on the UGG schema
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pro_teams"

    repo Lor.Repo

    migration_types name: :citext
  end

  identities do
    identity :name, [:name]
  end

  code_interface do
    define_for Lor.Pros
    define :create_from_ugg, args: [:team_data, :logo_id]
    define :by_names, args: [:names]
  end

  actions do
    defaults [:read]

    read :by_names do
      argument :names, {:array, :string} do
        allow_nil? false
      end

      filter expr(name in ^arg(:names))
    end

    create :create_from_ugg do
      accept []

      argument :team_data, :map do
        allow_nil? false
      end

      argument :logo_id, :uuid

      change Lor.Pros.Team.Changes.CreateFromUGG
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

  relationships do
    has_many :players, Lor.Pros.Player do
      destination_attribute :current_team_id
    end

    belongs_to :logo, Lor.S3.Object do
      api Lor.S3
      attribute_type :uuid
      attribute_writable? true
    end
  end
end
