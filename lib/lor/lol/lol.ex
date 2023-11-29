defmodule Lor.Lol do
  use Ash.Api

  resources do
    registry Lor.Lol.Registry
  end
end
