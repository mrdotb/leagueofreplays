defmodule Lor.Pros do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Lor.Pros.Team
    resource Lor.Pros.Player
  end
end
