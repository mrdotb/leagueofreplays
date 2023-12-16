defmodule Lor.Lol do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Lor.Lol.Match
    resource Lor.Lol.Summoner
    resource Lor.Lol.Participant
    resource Lor.Lol.Replay
    resource Lor.Lol.Chunk
    resource Lor.Lol.KeyFrame
  end
end
