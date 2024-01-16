defmodule Lor.Lol.Ddragon.Cache do
  @moduledoc """
  A local cache for ddragon
  """
  use Nebulex.Cache,
    otp_app: :lor,
    adapter: Nebulex.Adapters.Local
end
