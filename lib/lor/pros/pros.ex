defmodule Lor.Pros do
  use Ash.Api

  resources do
    resource Lor.Pros.Team
    resource Lor.Pros.Player
  end
end
