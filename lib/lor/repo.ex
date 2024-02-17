defmodule Lor.Repo do
  use AshPostgres.Repo, otp_app: :lor

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext", "pg_trgm"]
  end
end
