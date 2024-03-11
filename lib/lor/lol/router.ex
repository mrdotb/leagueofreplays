defmodule Lor.Lol.Router do
  use AshJsonApi.Api.Router,
    api: Lor.Lol,
    open_api: "/open_api"
end
