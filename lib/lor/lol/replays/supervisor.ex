defmodule Lor.Lol.Replays.Supervisor do
  @moduledoc """
  Organize the different process together.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children =
      if replays_active?() do
        [
          {Registry, keys: :unique, name: Lor.Lol.Replays.Registry},
          Lor.Lol.Replays.Manager,
          Lor.Lol.Replays.WorkerSupervisor,
          {Task.Supervisor, name: Lor.Lol.Replays.TaskSupervisor, strategy: :one_for_one}
        ] ++ featured_schedulers() ++ pro_schedulers()
      else
        []
      end

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp replays_active? do
    config = Application.get_env(:lor, :replays)
    Keyword.get(config, :active)
  end

  defp featured_schedulers do
    for platform_id <- Lor.Lol.PlatformIds.values() do
      name =
        {:via, Registry,
         {Lor.Lol.Replays.Registry, "featured_scheduler:#{to_string(platform_id)}"}}

      Supervisor.child_spec({Lor.Lol.Replays.FeaturedScheduler, {platform_id, name}}, id: name)
    end
  end

  defp pro_schedulers do
    []
  end
end
