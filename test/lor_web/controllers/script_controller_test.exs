defmodule LorWeb.ScriptControllerTest do
  use LorWeb.ConnCase, async: true

  test "GET /script/spectate success", %{conn: conn} do
    params = [
      endpoint: "lor",
      platform_id: "kr",
      game_id: "123456789",
      encryption_key: "key"
    ]

    conn = get(conn, ~p"/script/spectate?#{params}")
    assert response_content_type(conn, :bin)

    assert conn.resp_body =~ "KR"
    assert conn.resp_body =~ "123456789"
    assert conn.resp_body =~ "key"
  end

  test "GET /script/spectate failure", %{conn: conn} do
    params = [platform_id: "kr", encryption_key: "key"]

    assert_error_sent :internal_server_error, fn ->
      get(conn, ~p"/script/spectate?#{params}")
    end
  end
end
