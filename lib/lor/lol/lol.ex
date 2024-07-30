defmodule Lor.Lol do
  use Ash.Domain,
    extensions: [
      AshJsonApi.Api
    ]

  # json_api do
  #   prefix "/api/lol"
  #   router(Lor.Lol.Router)
  # end

  resources do
    resource Lor.Lol.Match
    resource Lor.Lol.Summoner
    resource Lor.Lol.Participant
    resource Lor.Lol.Replay
    resource Lor.Lol.Chunk
    resource Lor.Lol.KeyFrame
    resource Lor.Lol.ActiveGame
  end
end
