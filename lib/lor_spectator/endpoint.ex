defmodule LorSpectator.Endpoint do
  use Phoenix.Endpoint, otp_app: :lor

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug LorSpectator.Router
end
