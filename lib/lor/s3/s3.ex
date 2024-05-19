defmodule Lor.S3 do
  use Ash.Domain

  resources do
    resource Lor.S3.Object
  end
end
