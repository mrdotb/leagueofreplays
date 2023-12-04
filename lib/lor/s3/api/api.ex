defmodule Lor.S3.Api do
  @moduledoc """
  The api for S3
  """

  @behaviour Lor.S3.Behaviour
  @api Application.compile_env!(:lor, __MODULE__)

  @impl true
  def get_object(bucket, key),
    do: @api.get_object(bucket, key)

  @impl true
  def put_object(bucket, key, input),
    do: @api.put_object(bucket, key, input)

  @impl true
  def delete_object(bucket, key, input \\ %{}),
    do: @api.delete_object(bucket, key, input)

  @impl true
  def url(bucket, key),
    do: @api.url(bucket, key)
end
