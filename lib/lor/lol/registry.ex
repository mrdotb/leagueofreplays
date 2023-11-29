defmodule Lor.Lol.Registry do
  use Ash.Registry,
    extensions: [
      # This extension adds helpful compile time validations
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Lor.Lol.Match
    entry Lor.Lol.Summoner
    entry Lor.Lol.Participant
  end
end
