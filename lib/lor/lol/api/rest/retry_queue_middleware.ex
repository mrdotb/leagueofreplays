defmodule Lor.Lol.Rest.RetryQueueMiddleware do
  @moduledoc """
  A tesla middlware to rate limit the call and preserve the order using a queue
  """

  require Logger

  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, route) do
    id = Ecto.UUID.generate()
    queue_pid = get_queue_pid(route)

    Logger.debug("RetryQueueMiddleware new request id #{id}")

    :ok = Lor.Lol.Rest.Queue.push(queue_pid, id)

    context = %{
      id: id,
      queue_pid: queue_pid,
      queue_retries: 0,
      retries: 0,
      max_retries: 20,
      delay: 10_000,
      max_delay: 60_000,
      jitter_factor: 0.2
    }

    preserve_order(env, next, context)
  end

  defp get_queue_pid(route) do
    name = "queue:#{to_string(route)}"
    [{queue_pid, _}] = Registry.lookup(Lor.Lol.Rest.Registry, name)
    queue_pid
  end

  # Peek and check if it's our turn to request
  defp preserve_order(env, next, context) do
    with {:value, id} <- Lor.Lol.Rest.Queue.peek(context.queue_pid),
         true <- id === context.id do
      retry(env, next, context)
    else
      _other ->
        backoff(5_000, 1_000, context.queue_retries, context.jitter_factor)
        context = update_in(context, [:queue_retries], &(&1 + 1))
        preserve_order(env, next, context)
    end
  end

  defp should_retry?(res) do
    case res do
      {:ok, %{status: status}} when status in [429, 503] -> true
      {:ok, _} -> false
      {:error, _} -> true
    end
  end

  defp retry(env, next, context) do
    res = Tesla.run(env, next)

    if should_retry?(res) do
      do_retry(env, next, context)
    else
      {:value, id} = Lor.Lol.Rest.Queue.out(context.queue_pid)
      Logger.debug("RetryQueueMiddleware request done id #{id}")
      res
    end
  end

  defp do_retry(env, next, context) do
    backoff(context.max_delay, context.delay, context.retries, context.jitter_factor)
    context = update_in(context, [:retries], &(&1 + 1))
    retry(env, next, context)
  end

  # Exponential backoff with jitter
  defp backoff(cap, base, attempt, jitter_factor) do
    factor = Bitwise.bsl(1, attempt)
    max_sleep = min(cap, base * factor)

    # This ensures that the delay's order of magnitude is kept intact, while still having some jitter.
    # Generates a value x where 1 - jitter_factor <= x <= 1
    jitter = 1 - jitter_factor * :rand.uniform()

    # The actual delay is in the range max_sleep * (1 - jitter_factor) <= delay <= max_sleep
    delay = trunc(max_sleep * jitter)

    :timer.sleep(delay)
  end
end
