defmodule LorWeb.BasicAuthPlug do
  @moduledoc """
  A basic auth to securise specific route.
  """

  @behaviour Plug

  def init(config_key), do: config_key

  def call(conn, config_key) do
    basic_auth = get_basic_auth_config(config_key)

    if basic_auth[:enable?] do
      username = basic_auth[:username]
      password = basic_auth[:password]
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    else
      conn
    end
  end

  defp get_basic_auth_config(config_key) do
    Application.get_env(:lor, config_key)
  end
end
