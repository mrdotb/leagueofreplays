defmodule Lor.Lol.Replays.Supervisor do
  @moduledoc """
  Organize the different process together.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    config = Application.fetch_env!(:lor, :replay_schedulers)

    children =
      schedulers(config) ++
        featured_schedulers(config.featured) ++ pro_schedulers(config.pro)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp schedulers(%{active?: false}), do: []

  defp schedulers(%{active?: true}) do
    [
      {Registry, keys: :unique, name: Lor.Lol.Replays.Registry},
      Lor.Lol.Replays.WorkerSupervisor,
      Lor.Lol.Replays.Manager,
      {Task.Supervisor, name: Lor.Lol.Replays.TaskSupervisor, strategy: :one_for_one}
    ]
  end

  defp featured_schedulers(%{active?: false}), do: []

  defp featured_schedulers(%{active?: true, platform_ids: platform_ids}) do
    for platform_id <- platform_ids do
      name =
        {:via, Registry,
         {Lor.Lol.Replays.Registry, "featured_scheduler:#{to_string(platform_id)}"}}

      Supervisor.child_spec({Lor.Lol.Replays.FeaturedScheduler, {platform_id, name}}, id: name)
    end
  end

  defp pro_schedulers(%{active?: false}), do: []

  defp pro_schedulers(%{active?: true, platform_ids: platform_ids}) do
    for platform_id <- platform_ids do
      name =
        {:via, Registry, {Lor.Lol.Replays.Registry, "pro_scheduler:#{to_string(platform_id)}"}}

      Supervisor.child_spec({Lor.Lol.Replays.ProScheduler, {platform_id, name}}, id: name)
    end
  end
end
