defmodule Lor.Lol.Ddragon.Supervisor do
  @moduledoc """
  Organise the different process needed for Ddragon.
  """
  use Supervisor

  import Cachex.Spec

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    config = Application.fetch_env!(:lor, :ddragon)

    children = cache_child(config.cache)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp cache_child(%{active?: false}), do: []

  defp cache_child(%{active?: true}) do
    [
      {Cachex,
       name: Lor.Lol.Ddragon,
       warmers: [
         warmer(module: Lor.Lol.Ddragon.Warmer, state: nil, async: true)
       ]}
    ]
  end
end
