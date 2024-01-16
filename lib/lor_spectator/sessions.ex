defmodule LorSpectator.Sessions do
  @moduledoc """
  A local cache to track league client sessions.
  """
  use Nebulex.Cache,
    otp_app: :lor,
    adapter: Nebulex.Adapters.Local
end
