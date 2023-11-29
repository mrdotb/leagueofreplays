defmodule Lor.Lol.CreateMatchStep do
  @moduledoc "Run the create match flow"
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    platform_id = arguments.platform_id
    match_data = arguments.match_data
    s3_object = arguments.s3_object

    %{
      existing_summoners: existing_summoners,
      summoners_to_create: summoners_to_create
    } = arguments.summoners_data

    result =
      Lor.Lol.CreateMatchFlow.run(
        platform_id,
        match_data,
        s3_object,
        summoners_to_create,
        existing_summoners
      )

    if result.valid? do
      {:ok, result}
    else
      {:error, result}
    end
  end
end
