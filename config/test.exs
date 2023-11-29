import Config

# Ash
config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore

# S3
config :lor, Lor.S3.Api, Lor.S3Dummy

# Exvcr
config :exvcr,
  vcr_cassette_library_dir: "test/fixture/vcr_cassettes",
  custom_cassette_library_dir: "test/fixture/custom_cassettes",
  filter_sensitive_data: [],
  filter_url_params: false,
  filter_request_headers: ["X-Riot-Token"],
  response_headers_blacklist: []

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :lor, Lor.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "lor_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lor, LorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GtthBFVizZooSFwIFEZorc2xOinl4FsosfC10PnPdkL8GXQhHpK2IeeNTV2dlAA1",
  server: false

# In test we don't send emails.
config :lor, Lor.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

if File.exists?(Path.expand("dev.local.exs", __DIR__)) do
  import_config "test.local.exs"
end
