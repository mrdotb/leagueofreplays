defmodule Lor.Lol.ActiveGame.Participant.Calculations.LoadSummoner do
  use Ash.Calculation

  @impl true
  def load(_query, _opts, _context) do
    nil
  end

  @impl true
  def calculate(records, _opts, _) do
    {:ok, Enum.map(records, & &1.summoner)}
  end
end
