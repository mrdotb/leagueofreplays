defmodule Lor.S3 do
  @moduledoc "S3 api import & interactions"
  use Ash.Api

  resources do
    resource Lor.S3.Object
  end
end
