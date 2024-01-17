defmodule Lor.Lol.Ddragon.Supervisor do
  @moduledoc """
  Organise the different process needed for Ddragon.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    config = Application.fetch_env!(:lor, :ddragon)

    children =
      if config.cache.active? do
        [
          Lor.Lol.Ddragon.Cache,
          Lor.Lol.Ddragon.Warmer
        ]
      else
        []
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
