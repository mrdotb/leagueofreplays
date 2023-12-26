defmodule LorSpectator.Controller do
  use Phoenix.Controller

  import Plug.Conn

  def action(%{private: %{phoenix_action: action}} = conn, _)
      when action in ~w(get_game_meta_data get_last_chunk_info get_game_data_chunk get_key_frame)a do
    params = LorSpectator.Helpers.add_session_params!(conn.params)
    apply(__MODULE__, action_name(conn), [conn, params])
  end

  def action(conn, _) do
    apply(__MODULE__, :version, [conn, conn.params])
  end

  def version(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "2.0.0")
  end

  def get_game_meta_data(conn, params) do
    types = [platform_id: {:string, required: true}, game_id: {:string, required: true}]
    args = Lor.Validation.normalize!(params, types)
    replay = Lor.Lol.Replay.get_by_game_id_and_platform_id!(args.platform_id, args.game_id)
    json(conn, replay.game_meta_data)
  end

  def get_last_chunk_info(conn, params) do
    types = [
      platform_id: {:string, required: true},
      game_id: {:string, required: true},
      session_id: {:string, required: true}
    ]

    args = Lor.Validation.normalize!(params, types)
    replay = Lor.Lol.Replay.get_by_game_id_and_platform_id!(args.platform_id, args.game_id)

    response =
      LorSpectator.Helpers.get_last_chunk_info(
        replay,
        args.game_id,
        args.session_id
      )

    json(conn, response)
  end

  def get_game_data_chunk(conn, params) do
    types = [
      platform_id: {:string, required: true},
      game_id: {:string, required: true},
      chunk_id: {:integer, required: true}
    ]

    args = Lor.Validation.normalize!(params, types)
    url = LorSpectator.Helpers.get_chunk_url(args)
    redirect(conn, external: url)
  end

  def get_key_frame(conn, params) do
    types = [
      platform_id: {:string, required: true},
      game_id: {:string, required: true},
      key_frame_id: {:integer, required: true}
    ]

    args = Lor.Validation.normalize!(params, types)
    url = LorSpectator.Helpers.get_key_frame_url(args)
    redirect(conn, external: url)
  end
end
