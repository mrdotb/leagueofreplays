defmodule Lor.S3Dummy do
  @moduledoc """
  S3 api implementation for tests.
  """
  @behaviour Lor.S3.Behaviour

  @impl true
  def get_object(_bucket, _key) do
    {:ok, %{}}
  end

  @impl true
  def put_object(_bucket, _key, _input) do
    {:ok, %{}}
  end

  @impl true
  def delete_object(_bucket, _key, _input) do
    {:ok, %{}}
  end
end
