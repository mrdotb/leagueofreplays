defmodule LorSpectator.ControllerTest do
  use LorSpectator.ConnCase

  test "GET /version", %{conn: conn} do
    conn = get(conn, ~p"/observer-mode/rest/consumer/version")
    assert text_response(conn, 200) == "2.0.0"
  end

  test "GET /getGameMetaData success", %{conn: conn} do
    params = %{
      platform_id: :euw1,
      game_id: "6720928471",
      game_meta_data: %{},
      encryption_key: "lmmwcqeQfVEGpRtMHLd5634xeIlAtpL4"
    }

    Lor.Lol.Replay.create!(params)

    route = ~p"/observer-mode/rest/consumer/getGameMetaData/EUW1-12345689/6720928471/1/token"
    conn = get(conn, route)

    assert json_response(conn, 200) == %{}
  end

  test "GET /getGameMetaData failure missing session id or platform id", %{conn: conn} do
    route = ~p"/observer-mode/rest/consumer/getGameMetaData/EUW1/6720928471/1/token"

    assert_error_sent :unprocessable_entity, fn ->
      get(conn, route)
    end
  end

  test "GET /getGameMetaData failure missing replay id", %{conn: conn} do
    route = ~p"/observer-mode/rest/consumer/getGameMetaData/EUW1-123/6720928471/1/token"

    assert_error_sent :not_found, fn ->
      get(conn, route)
    end
  end

  test "GET /getLastChunkInfo success", %{conn: conn} do
    params = %{
      platform_id: :euw1,
      game_id: "6720928471",
      game_meta_data: %{},
      encryption_key: "lmmwcqeQfVEGpRtMHLd5634xeIlAtpL4"
    }

    Lor.Lol.Replay.create!(params)

    route = ~p"/observer-mode/rest/consumer/getLastChunkInfo/EUW1-12345689/6720928471/1/token"
    conn = get(conn, route)

    assert json_response(conn, 200) ==
             %{
               "availableSince" => 30000,
               "chunkId" => 2,
               "duration" => 30000,
               "endGameChunkId" => 0,
               "endStartupChunkId" => 1,
               "keyFrameId" => 1,
               "nextAvailableChunk" => 10000,
               "nextChunkId" => 2,
               "startGameChunkId" => 2
             }
  end
end
