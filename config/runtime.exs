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

  config :lor, Lor.S3.Minio,
    access_key: access_key,
    secret_key: secret_key,
    endpoint: s3_endpoint,
    port: 443,
    proto: "https"

  s3_bucket_pictures = System.get_env("S3_BUCKET_PICTURES") || "pictures"
  s3_bucket_replays = System.get_env("S3_BUCKET_REPLAYS") || "replays"
  s3_bucket_original = System.get_env("S3_BUCKET_ORIGINAL") || "original"

  s3_replay_url =
    System.get_env("S3_REPLAY_URL") ||
      raise """
      environment variable S3_REPLAY_URL is missing.
      """

  config :lor, :s3, %{
    buckets: %{
      pictures: s3_bucket_pictures,
      replays: s3_bucket_replays,
      original: s3_bucket_original
    },
    urls: %{
      replays: s3_replay_url
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
  port = String.to_integer(System.get_env("PHX_PORT") || "4000")

  config :lor, LorWeb.Endpoint,
    server: phx_server,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  admin_password =
    System.get_env("ADMIN_PASSWORD") || nil

  if is_binary(admin_password) do
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

  spectator_port = String.to_integer(System.get_env("SPECTATOR_PORT") || "3000")

  config :lor, LorSpectator.Endpoint,
    server: spectator_server,
    url: [scheme: "http", host: spectator_host, port: spectator_port, path: "/"],
    http: [
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

  queue_count = String.to_integer(System.get_env("QUEUE_COUNT") || "10")
  queue_pro_platform_ids = platform_ids_from_env.("QUEUE_PRO_PLATFORMS")

  config :lor, Oban,
    repo: Lor.Repo,
    queues: [default: queue_count],
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
end
