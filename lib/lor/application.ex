defmodule Lor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Lor.Repo,
      {Phoenix.PubSub, name: :lor_pubsub},
      {Oban, AshOban.config([Lor.Lol, Lor.Pros, Lor.S3], Application.fetch_env!(:lor, Oban))},
      LorSpectator.Supervisor,
      LorWeb.Telemetry,
      LorWeb.Endpoint,
      Lor.Lol.Ddragon.Supervisor,
      Lor.Lol.Rest.Supervisor,
      Lor.Lol.Observer.Clients,
      Lor.Lol.Replays.Supervisor,
      {Cluster.Supervisor,
       [Application.fetch_env!(:libcluster, :topologies), [name: Lor.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
