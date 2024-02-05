# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lor, :admin_dashboard, enable?: false

config :lor,
  ash_apis: [
    Lor.Lol,
    Lor.Pros,
    Lor.S3
  ]

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

# Ddragon
config :lor,
  ddragon: %{
    cache: %{
      active?: true
    }
  }

config :tesla, adapter: Tesla.Adapter.Hackney

config :lor, Lor.S3.Api, Lor.S3.Minio

config :lor,
  ecto_repos: [Lor.Repo],
  generators: [timestamp_type: :utc_datetime]

# Oban config
config :lor, Oban, repo: Lor.Repo

# Configures the web endpoint
config :lor, LorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: LorWeb.ErrorHTML, json: LorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: :lor_pubsub,
  live_view: [signing_salt: "0uxjtFvk"]

config :lor, LorSpectator.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [text: LorSpectator.ErrorText]
  ]

config :mime, :suffixes, %{
  "bat" => ["bin"]
}

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :lor, Lor.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Nebulex caches
config :lor, LorSpectator.Sessions, backend: :ets

config :lor, Lor.Lol.Ddragon.Cache, backend: :ets

# libcluster
config :libcluster,
  topologies: [
    api: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: []
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
