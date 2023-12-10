defmodule Lor.Lol.Rest.Supervisor do
  @moduledoc """
  Organize the different process to make the lol rest api working.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children =
      [
        {Registry, keys: :unique, name: Lor.Lol.Rest.Registry},
        Lor.Lol.RestClients
      ] ++ queues()

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp queues do
    platform_ids = Lor.Lol.PlatformIds.values()
    regions = Lor.Lol.Regions.values()

    routes = platform_ids ++ regions

    for route <- routes do
      name = {:via, Registry, {Lor.Lol.Rest.Registry, "queue:#{to_string(route)}"}}
      Supervisor.child_spec({Lor.Lol.Rest.Queue, name}, id: name)
    end
  end
end
