defmodule LorSpectator.Endpoint do
  use Phoenix.Endpoint, otp_app: :lor

  plug LorSpectator.Router
end
