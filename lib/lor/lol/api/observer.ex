defmodule Lor.Lol.Observer do
  @moduledoc """
  A thing wrapper around the observer api.
  """

  def new(opts) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, url(opts)},
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end

  defp url(platform_id) when is_atom(platform_id) do
    platform_id = to_string(platform_id)
    "http://spectator-consumer.#{platform_id}.lol.pvp.net:80"
  end

  # allow arbitrary base url for unoffical spectator api
  defp url(base_url) when is_binary(base_url) do
    base_url
  end

  def fetch_api_version(platform_id) do
    client = Lor.Lol.ObserverClients.get_client(platform_id)
    path = "/observer-mode/rest/consumer/version"

    with {:ok, %{body: version, status: 200}} <- Tesla.get(client, path) do
      {:ok, version}
    end
  end

  def fetch_game_meta_data(platform_id, game_id) do
    client = Lor.Lol.ObserverClients.get_client(platform_id)

    path =
      "/observer-mode/rest/consumer/getGameMetaData/#{to_string(platform_id)}/#{game_id}/1/token"

    with {:ok, %{body: body, status: 200}} <- Tesla.get(client, path) do
      Jason.decode(body)
    end
  end

  def fetch_last_chunk_info(platform_id, game_id) do
    client = Lor.Lol.ObserverClients.get_client(platform_id)

    path =
      "/observer-mode/rest/consumer/getLastChunkInfo/#{to_string(platform_id)}/#{game_id}/0/token"

    with {:ok, %{body: body, status: 200}} <- Tesla.get(client, path) do
      Jason.decode(body)
    end
  end

  def fetch_game_data_chunk(platform_id, game_id, chunk_id) do
    client = Lor.Lol.ObserverClients.get_client(platform_id)

    path =
      "/observer-mode/rest/consumer/getGameDataChunk/#{to_string(platform_id)}/#{game_id}/#{chunk_id}/token"

    with {:ok, %{body: body, status: 200}} <- Tesla.get(client, path) do
      {:ok, body}
    end
  end

  def fetch_key_frame(platform_id, game_id, keyframe_id) do
    client = Lor.Lol.ObserverClients.get_client(platform_id)

    path =
      "/observer-mode/rest/consumer/getKeyFrame/#{to_string(platform_id)}/#{game_id}/#{keyframe_id}/token"

    with {:ok, %{body: body, status: 200}} <- Tesla.get(client, path) do
      {:ok, body}
    end
  end
end
