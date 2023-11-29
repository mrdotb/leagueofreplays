defmodule Lor.Lol.FetchMatchStep do
  @moduledoc "Fetch the match_data from riot api"
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    Lor.Lol.Rest.fetch_match(arguments.region, arguments.match_id)
  end
end
