defmodule Lor.Pros.Router do
  use AshJsonApi.Router,
    domains: [Module.concat(["Lor.Pros"])]
end
