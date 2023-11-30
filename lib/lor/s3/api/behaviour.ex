defmodule Lor.S3.Behaviour do
  @moduledoc false

  @callback get_object(
              bucket :: binary(),
              key :: binary()
            ) :: {:ok, map()} | {:error, {atom(), map()}}

  @callback put_object(
              bucket :: binary(),
              key :: binary(),
              input :: map()
            ) :: {:ok, map()} | {:error, {atom(), map()}}

  @callback delete_object(
              bucket :: binary(),
              key :: binary(),
              input :: map()
            ) :: {:ok, map()} | {:error, {atom(), map()}}
end
