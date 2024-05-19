defmodule Lor.Pros do
  use Ash.Domain

  resources do
    resource Lor.Pros.Team
    resource Lor.Pros.Player
  end
end
