import Config

# Ash
config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore

# Replay schedulers
config :lor,
  replay_schedulers: %{
    active?: false,
    featured: %{
      active?: false,
      platform_ids: []
    },
    pro: %{
      active?: false,
      platform_ids: []
    }
  }

# S3
config :lor, Lor.S3.Api, Lor.S3Dummy

# Oban
config :lor, Oban, testing: :manual

# Ddragon
config :lor,
  ddragon: %{
    cache: %{
      active?: false
    }
  }

# s3
config :lor, :s3, %{
  buckets: %{
    pictures: "pictures",
    replays: "replays",
    original: "original"
  },
  urls: %{
    replays: ""
  }
}

# Exvcr
config :exvcr,
  global_mock: true,
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

# We don't run a web server during test. If one is required,
# you can enable the server option below.
config :lor, LorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GtthBFVizZooSFwIFEZorc2xOinl4FsosfC10PnPdkL8GXQhHpK2IeeNTV2dlAA1",
  server: false

config :lor, LorSpectator.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4003],
  debug_errors: false,
  server: false,
  url: [scheme: "http", host: "localhost", port: 4003, path: "/"]

# Replays schedulers
config :lor,
  replay_schedulers: %{
    active?: true,
    featured: %{
      active?: false,
      platform_ids: [:kr]
    },
    pro: %{
      active?: false,
      platform_ids: [:kr]
    }
  }

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
