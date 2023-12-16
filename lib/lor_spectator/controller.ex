defmodule LorSpectator.Controller do
  use Phoenix.Controller

  import Plug.Conn

  @doc """
  Split the platform_id and the session id
  """
  def action(conn, _) do
    if action_name(conn) == :version do
      apply(__MODULE__, :version, [conn, conn.params])
    else
      {platform_id, session_id} = split_platform_id_and_session_id(conn.params["platform_id"])
      params = Map.merge(conn.params, %{"platform_id" => platform_id, "session_id" => session_id})
      apply(__MODULE__, action_name(conn), [conn, params])
    end
  end

  defp split_platform_id_and_session_id(string) do
    case String.split(string, "-", part: 2) do
      [platform_id, session_id] ->
        {platform_id, session_id}

      _ ->
        {nil, nil}
    end
  end

  def version(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "2.0.0")
  end

  def get_game_meta_data(conn, _params) do
    json(conn, %{})
  end

  def get_last_chunk_info(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "2.0.0")
  end

  def get_game_data_chunk(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "2.0.0")
  end

  def get_key_frame(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "2.0.0")
  end
end
