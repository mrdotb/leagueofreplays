defmodule Lor.Lol.Router do
  use AshJsonApi.Api.Router,
    apis: [Lor.Lol],
    open_api: "/open_api"
end
