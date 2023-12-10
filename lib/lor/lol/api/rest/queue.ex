defmodule Lor.Lol.Rest.Queue do
  @moduledoc """
  A simple :queue wrapped in an agent for the RetryQueueMiddleware
  """
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> :queue.new() end, name: name)
  end

  def push(pid, id) do
    Agent.update(pid, fn queue ->
      :queue.in(id, queue)
    end)
  end

  def peek(pid) do
    Agent.get(pid, fn queue ->
      :queue.peek(queue)
    end)
  end

  def out(pid) do
    Agent.get_and_update(pid, fn queue ->
      :queue.out(queue)
    end)
  end
end
