defmodule Lor.Repo.Migrations.CreateProTables do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:pro_teams, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :name, :citext, null: false
      add :short_name, :text
      add :liquidpedia_url, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :logo_id,
          references(:s3_objects,
            column: :id,
            name: "pro_teams_logo_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:pro_teams, [:name], name: "pro_teams_name_index")

    create table(:pro_players, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :normalized_name, :citext, null: false
      add :official_name, :text, null: false
      add :liquidpedia_url, :text
      add :main_role, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :current_team_id,
          references(:pro_teams,
            column: :id,
            name: "pro_players_current_team_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :picture_id,
          references(:s3_objects,
            column: :id,
            name: "pro_players_picture_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:pro_players, [:normalized_name],
             name: "pro_players_normalized_name_index"
           )

    create unique_index(:pro_players, [:official_name], name: "pro_players_official_name_index")

    alter table(:lol_summoners) do
      add :player_id,
          references(:pro_players,
            column: :id,
            name: "lol_summoners_player_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:lol_summoners, "lol_summoners_player_id_fkey")

    alter table(:lol_summoners) do
      remove :player_id
    end

    drop_if_exists unique_index(:pro_players, [:official_name],
                     name: "pro_players_official_name_index"
                   )

    drop_if_exists unique_index(:pro_players, [:normalized_name],
                     name: "pro_players_normalized_name_index"
                   )

    drop constraint(:pro_players, "pro_players_current_team_id_fkey")

    drop constraint(:pro_players, "pro_players_picture_id_fkey")

    drop table(:pro_players)

    drop_if_exists unique_index(:pro_teams, [:name], name: "pro_teams_name_index")

    drop constraint(:pro_teams, "pro_teams_logo_id_fkey")

    drop table(:pro_teams)
  end
end
