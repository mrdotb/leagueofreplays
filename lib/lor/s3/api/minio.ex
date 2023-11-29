defmodule Lor.S3.Minio do
  @moduledoc """
  Implementation for minio S3
  """

  @behaviour Lor.S3.Behaviour

  require Logger

  defp get_config, do: Application.get_env(:lor, __MODULE__)

  defp create_client do
    config = get_config()
    access_key = config[:access_key]
    secret_key = config[:secret_key]
    endpoint = config[:endpoint]
    proto = config[:proto]
    port = config[:port]

    client = AWS.Client.create(access_key, secret_key, "")
    %{client | proto: proto, port: port, endpoint: endpoint}
  end

  @impl true
  def get_object(bucket, key) do
    client = create_client()

    case AWS.S3.get_object(client, bucket, key) do
      {:ok, _body, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error("Minio error: #{inspect(error)}")
        {:error, error}
    end
  end

  defp build_object_input(input) do
    Enum.reduce(input, %{}, &reduce_object_input/2)
  end

  defp reduce_object_input({:body, value}, acc), do: Map.put(acc, "Body", value)
  defp reduce_object_input({:content_type, value}, acc), do: Map.put(acc, "ContentType", value)
  defp reduce_object_input({:md5, value}, acc), do: Map.put(acc, "ContentMD5", value)

  @impl true
  def put_object(bucket, key, input) do
    client = create_client()
    input = build_object_input(input)

    case AWS.S3.put_object(client, bucket, key, input) do
      {:ok, _body, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error("Minio error: #{inspect(error)}")
        {:error, error}
    end
  end
end
