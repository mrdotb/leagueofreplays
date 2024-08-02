import Config

if config_env() == :prod do
  # Common

  # helpers

  platform_ids_from_env = fn env ->
    System.get_env(env)
    |> Kernel.||("")
    |> String.split(",", trim: true)
    |> Enum.map(fn platform_id ->
      {:ok, platform_id} = Lor.Lol.PlatformIds.match(platform_id)
      platform_id
    end)
  end

  oban_queues = fn ->
    System.get_env("OBAN_QUEUES")
    |> Kernel.||("")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Keyword.new(fn [queue, limit] ->
      {String.to_existing_atom(queue), String.to_integer(limit)}
    end)
  end

  ## Postgres

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :lor, Lor.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  ## Riot client

  riot_token =
    System.get_env("RIOT_TOKEN") ||
      raise """
      environment variable RIOT_TOKEN is missing.
      """

  config :lor, Lor.Lol.Rest.Client, token: riot_token

  ## S3

  access_key =
    System.get_env("S3_ACCESS_KEY") ||
      raise """
      environment variable S3_ACCESS_KEY is missing.
      """

  secret_key =
    System.get_env("S3_SECRET_KEY") ||
      raise """
      environment variable S3_SECRET_KEY is missing.
      """

  s3_endpoint =
    System.get_env("S3_ENDPOINT") ||
      raise """
      environment variable S3_ENDPOINT is missing.
      """

  s3_port = String.to_integer(System.get_env("S3_PORT") || "9000")
  s3_proto = System.get_env("S3_PROTO") || "http"

  config :lor, Lor.S3.Minio,
    access_key: access_key,
    secret_key: secret_key,
    endpoint: s3_endpoint,
    port: s3_port,
    proto: s3_proto

  s3_bucket_pictures = System.get_env("S3_BUCKET_PICTURES") || "pictures"
  s3_bucket_replays = System.get_env("S3_BUCKET_REPLAYS") || "replays"
  s3_bucket_original = System.get_env("S3_BUCKET_ORIGINAL") || "original"

  s3_pictures_url =
    System.get_env("S3_PICTURES_URL") ||
      raise """
      environment variable S3_PICTURES_URL is missing.
      """

  s3_replays_url =
    System.get_env("S3_REPLAYS_URL") ||
      raise """
      environment variable S3_REPLAYS_URL is missing.
      """

  config :lor, :s3, %{
    buckets: %{
      pictures: s3_bucket_pictures,
      replays: s3_bucket_replays,
      original: s3_bucket_original
    },
    urls: %{
      pictures: s3_pictures_url,
      replays: s3_replays_url
    }
  }

  ## Libcluster k8s

  libcluster? = if System.get_env("LIBCLUSTER") in ~w(true 1), do: true, else: false

  if libcluster? do
    node_basename =
      System.get_env("K8_NODE_BASENAME") ||
        raise """
        environment variable K8_NODE_BASENAME is missing.
        """

    selector =
      System.get_env("K8_SELECTOR") ||
        raise """
        environment variable K8_SELECTOR is missing.
        """

    namespace =
      System.get_env("K8_NAMESPACE") ||
        raise """
        environment variable K8_NAMESPACE is missing.
        """

    config :libcluster,
      topologies: [
        erlang_nodes_in_k8s: [
          strategy: Elixir.Cluster.Strategy.Kubernetes,
          config: [
            mode: :dns,
            kubernetes_node_basename: node_basename,
            kubernetes_selector: selector,
            kubernetes_namespace: namespace,
            polling_interval: 10_000
          ]
        ]
      ]
  end

  # Web server

  phx_server = if System.get_env("PHX_SERVER") in ~w(true 1), do: true, else: false

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      """

  host = System.get_env("PHX_HOST") || "localhost"
  public_port = String.to_integer(System.get_env("PHX_PUB_PORT") || "443")
  public_scheme = System.get_env("PHX_PUB_SCHEME") || "https"
  port = String.to_integer(System.get_env("PHX_PORT") || "4000")

  config :lor, LorWeb.Endpoint,
    server: phx_server,
    url: [host: host, port: public_port, scheme: public_scheme],
    http: [
      # Enable IPv6 and bind on all interfaces.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  admin_password =
    System.get_env("ADMIN_PASSWORD") || nil

  if is_binary(admin_password) and admin_password != "" do
    config :lor, :admin_dashboard,
      enable?: true,
      username: "admin",
      password: admin_password
  end

  ddragon_cache? = if System.get_env("DDRAGON_CACHE") in ~w(true 1), do: true, else: false

  config :lor,
    ddragon: %{
      cache: %{active?: ddragon_cache?}
    }

  # Spectator server

  spectator_server = if System.get_env("SPECTATOR_SERVER") in ~w(true 1), do: true, else: false

  spectator_host = System.get_env("SPECTATOR_HOST") || "localhost"
  spectator_public_port = String.to_integer(System.get_env("SPECTATOR_PUB_PORT") || "80")
  spectator_port = String.to_integer(System.get_env("SPECTATOR_PORT") || "3000")

  config :lor, LorSpectator.Endpoint,
    server: spectator_server,
    # Client api only support http scheme
    url: [host: spectator_host, port: spectator_public_port, scheme: "http"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: spectator_port
    ]

  # Schedulers

  scheduler? = if System.get_env("SCHEDULER") in ~w(true 1), do: true, else: false
  pro_scheduler? = if System.get_env("PRO_SCHEDULER") in ~w(true 1), do: true, else: false

  scheduler_platform_ids = platform_ids_from_env.("SCHEDULER_PLATFORMS")

  config :lor,
    replay_schedulers: %{
      active?: scheduler?,
      featured: %{
        active?: false,
        platform_ids: []
      },
      pro: %{
        active?: pro_scheduler?,
        platform_ids: scheduler_platform_ids
      }
    }

  # Oban

  queue_pro_platform_ids = platform_ids_from_env.("QUEUE_PRO_PLATFORMS")

  config :lor, Oban,
    repo: Lor.Repo,
    queues: oban_queues.(),
    plugins: [
      {Oban.Plugins.Pruner, max_age: 3600 * 2},
      {Oban.Plugins.Lifeline, rescue_after: :timer.hours(1)},
      {
        Oban.Plugins.Cron,
        crontab:
          for platform_id <- queue_pro_platform_ids do
            {"@daily", Lor.Pros.ProWorker, args: %{"platform_id" => platform_id}}
          end
      }
    ]

  # Discord Logger

  discord_logger? = if System.get_env("DISCORD_LOGGER") in ~w(true 1), do: true, else: false

  if discord_logger? do
    discord_token =
      System.get_env("DISCORD_TOKEN") ||
        raise """
        environment variable DISCORD_TOKEN is missing.
        """

    discord_info_channel_id =
      System.get_env("DISCORD_INFO_CHANNEL_ID") ||
        raise """
        environment variable DISCORD_INFO_CHANNEL_ID is missing.
        """

    discord_error_channel_id =
      System.get_env("DISCORD_ERROR_CHANNEL_ID") ||
        raise """
        environment variable DISCORD_ERROR_CHANNEL_ID is missing.
        """

    config :logger,
      level: :info,
      backends: [
        :console,
        {
          Lor.Discord.Logger,
          :discord_logger
        }
      ]

    config :lor, Ttr.Discord.Client, token: discord_token

    config :logger, :discord_logger,
      channel_info: discord_info_channel_id,
      channel_error: discord_error_channel_id,
      level: :info,
      info_format: "`$time $message`",
      error_format: """
      `$time $metadata[module] $metadata[function] $metadata[file]:$metadata[line]`
      $message
      """,
      metadata: [:application, :module, :function, :file, :line]
  end
end
