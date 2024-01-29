defmodule Lor.S3 do
  use Ash.Api

  resources do
    resource Lor.S3.Object
  end
end
