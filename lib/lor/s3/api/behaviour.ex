defmodule Lor.S3.Behaviour do
  @moduledoc false

  @callback get_object(
              bucket :: binary(),
              key :: binary()
            ) :: {:ok, map()} | {:error, map()}

  @callback put_object(
              bucket :: binary(),
              key :: binary(),
              input :: binary()
            ) :: {:ok, map()} | {:error, map()}
end
