defmodule LorSpectator.Supervisor do
  @moduledoc """
  Organise the different process needed for LorSpectator.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      LorSpectator.Endpoint,
      {LorSpectator.Cache, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
