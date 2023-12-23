defmodule Lor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LorWeb.Telemetry,
      Lor.Repo,
      {DNSCluster, query: Application.get_env(:lor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lor.PubSub},
      # Start the Finch HTTP client
      {Finch, name: Lor.Finch},
      # Ddragon
      Lor.Lol.Ddragon.Supervisor,
      # Start our HTTP clients
      Lor.Lol.Rest.Supervisor,
      Lor.Lol.Observer.Clients,
      # Oban
      {Oban, AshOban.config([Lor.Lol], Application.fetch_env!(:lor, Oban))},
      # Start Replays
      Lor.Lol.Replays.Supervisor,
      # Start to serve requests, typically the last entry
      LorWeb.Endpoint,
      # Start Spectator endpoint
      LorSpectator.Supervisor
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
