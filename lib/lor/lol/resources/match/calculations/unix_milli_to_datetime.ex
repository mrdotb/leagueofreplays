defmodule Lor.Lol.Match.Calculations.UnixMilliToDateTime do
  use Ash.Calculation

  @impl true
  def load(_query, opts, _context) do
    [opts[:key]]
  end

  @impl true
  def calculate(records, opts, _args) do
    Enum.map(records, fn record ->
      record
      |> Map.get(opts[:key])
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.truncate(:second)
    end)
  end
end
