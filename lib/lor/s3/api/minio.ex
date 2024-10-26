defmodule Lor.S3.Minio do
  @moduledoc """
  Implementation for minio S3
  """

  @behaviour Lor.S3.Behaviour

  require Logger

  defp create_client do
    config = Application.get_env(:lor, __MODULE__)
    access_key = config[:access_key]
    secret_key = config[:secret_key]
    endpoint = config[:endpoint]
    proto = config[:proto]
    port = config[:port]

    client = AWS.Client.create(access_key, secret_key, "")
    %{client | proto: proto, port: port, endpoint: endpoint}
  end

  defp process_response({:ok, _body, response}) do
    {:ok, response}
  end

  defp process_response({:error, error}) do
    Logger.error("Minio error: #{inspect(error)}")
    {:error, error}
  end

  @impl true
  def get_object(bucket, key) do
    create_client()
    |> AWS.S3.get_object(bucket, key)
    |> process_response()
  end

  defp build_object_input(input) do
    Enum.reduce(input, %{}, &reduce_object_input/2)
  end

  defp reduce_object_input({:body, value}, acc), do: Map.put(acc, "Body", value)
  defp reduce_object_input({:content_type, value}, acc), do: Map.put(acc, "ContentType", value)
  defp reduce_object_input({:md5, value}, acc), do: Map.put(acc, "ContentMD5", value)

  @impl true
  def put_object(bucket, key, input) do
    input = build_object_input(input)

    create_client()
    |> AWS.S3.put_object(bucket, key, input)
    |> process_response()
  end

  @impl true
  def delete_object(bucket, key, input) do
    create_client()
    |> AWS.S3.delete_object(bucket, key, input)
    |> process_response()
  end

  @impl true
  def url(bucket, key) do
    s3_config = Application.get_env(:lor, :s3)
    {bucket_key, _} =
      Enum.find(s3_config.buckets, fn {_bucket_key, bucket_value} -> bucket_value == bucket end)
    urls = s3_config.urls
    base_url = Map.fetch!(urls, bucket_key)

    "#{base_url}/#{key}"
  end
end
