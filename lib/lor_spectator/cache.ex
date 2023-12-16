defmodule LorSpectator.Cache do
  use Nebulex.Cache,
    otp_app: :lor,
    adapter: Nebulex.Adapters.Local
end
