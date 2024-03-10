alias Lor.Lol.{
  Participant
}

alias Lor.Pros.Team
alias Lor.Pros.Player

defmodule U do
  def json_routes do
    [Participant, Team, Player]
    |> Enum.flat_map(&AshJsonApi.Resource.Info.routes(&1))
    |> Enum.each(&IO.puts(&1.route))
  end
end
