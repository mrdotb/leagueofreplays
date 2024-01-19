defmodule LorWeb.ScriptController do
  use Phoenix.Controller, formats: [:bat]

  def spectate(conn, params) do
    types = [
      endpoint: {:string, required: true},
      platform_id: {:string, required: true},
      game_id: {:string, required: true},
      encryption_key: {:string, required: true}
    ]

    args = Lor.Validation.normalize!(params, types)
    platform_id = String.upcase(args.platform_id)
    encryption_key = String.replace(args.encryption_key, " ", "+")
    file_name = "Lor_Game_#{platform_id}_#{args.game_id}.bat"

    conn
    |> put_resp_content_type("application/octet-stream")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{file_name}\"")
    |> render("spectate.bat",
      layout: false,
      spectator_endpoint:
        LorWeb.ScriptHelpers.spectator_endpoint(args.endpoint, args.platform_id),
      encryption_key: encryption_key,
      game_id: args.game_id,
      platform_id: LorWeb.ScriptHelpers.get_platform_id(:windows, args.endpoint, args.platform_id)
    )
  end
end
