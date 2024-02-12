defmodule Lor.Pros.ProWorker do
  use Oban.Worker

  require Logger

  @impl true
  def perform(%{args: %{"platform_id" => platform_id}}) do
    {:ok, platform_id} = Lor.Lol.PlatformIds.match(platform_id)

    case Reactor.run(Lor.Pros.UGGReactor, %{platform_id: platform_id}) do
      {:ok, _result} ->
        :ok

      {:error, error} ->
        {:error, error}
    end
  end
end
