defmodule Lor.Repo do
  use Ecto.Repo,
    otp_app: :lor,
    adapter: Ecto.Adapters.Postgres
end
