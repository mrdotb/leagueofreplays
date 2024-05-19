defmodule Lor.Lol.Router do
  use AshJsonApi.Router,
    domains: [Module.concat(["Lor.Lol"])],
    open_api: "/open_api"
end
