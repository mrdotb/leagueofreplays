defmodule LorSpectator.ControllerTest do
  use LorSpectator.ConnCase

  test "GET /version", %{conn: conn} do
    conn = get(conn, ~p"/observer-mode/rest/consumer/version")
    assert text_response(conn, 200) == "2.0.0"
  end

  test "GET /getGameMetaData", %{conn: conn} do
    route = ~p"/observer-mode/rest/consumer/getGameMetaData/KR-123/123/1/token"
    conn = get(conn, route)

    json_response(conn, 200)
    |> IO.inspect()
  end
end
