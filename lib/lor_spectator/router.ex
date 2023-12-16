defmodule LorSpectator.Router do
  use Phoenix.Router, helpers: false

  import Plug.Conn

  scope "/observer-mode/rest/consumer", LorSpectator do
    get "/version", Controller, :version
    get "/getGameMetaData/:platform_id/:game_id/:_/token", Controller, :get_game_meta_data
    get "/getLastChunkInfo/:platform_id/:game_id/:_/token", Controller, :get_last_chunk_info

    get "/getGameDataChunk/:platform_id/:game_id/:chunk_id/token",
        Controller,
        :get_game_data_chunk

    get "/getKeyFrame/:platform_id/:game_id/:key_frame_id/token", Controller, :get_key_frame
  end
end
