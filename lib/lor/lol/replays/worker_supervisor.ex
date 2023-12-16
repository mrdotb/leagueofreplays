defmodule Lor.Lol.Replays.WorkerSupervisor do
  @moduledoc """
  DynamicSupervisor to work on active game
  """

  use DynamicSupervisor

  require Logger

  @doc "Start the supervisor"
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  @doc "Start a new replay worker under the supervisor"
  def add(args) do
    DynamicSupervisor.start_child(__MODULE__, {Lor.Lol.Replays.Worker, args})
  end

  @doc "Remove a replay worker under the supervisor"
  def remove(child_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  # Callbacks

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
