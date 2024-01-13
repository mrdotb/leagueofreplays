defmodule Lor.Lol.Observer.Client do
  @moduledoc """
  A thing wrapper around the observer api.
  """

  require Logger

  def new(opts) do
    middlewares = [
      {Tesla.Middleware.Retry,
       [
         delay: 100,
         max_retries: 3,
         max_delay: 500,
         should_retry: fn
           {:ok, %{status: 404}} -> true
           {:ok, _} -> false
           {:error, _} -> true
         end
       ]},
      {Tesla.Middleware.BaseUrl, url(opts)}
      # Logger
      # Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end

  defp url(platform_id) when is_atom(platform_id) do
    platform_id = to_string(platform_id)
    # "http://spectator-consumer.#{platform_id}.lol.pvp.net:8080"
    "http://spectator.#{platform_id}.lol.pvp.net:8080"
  end

  # allow arbitrary base url for unoffical spectator api
  defp url(base_url) when is_binary(base_url) do
    base_url
  end

  def fetch_api_version(client) do
    path = "/observer-mode/rest/consumer/version"

    case Tesla.get!(client, path) do
      %{status: 200, body: version} ->
        {:ok, version}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  def fetch_game_meta_data(client, platform_id, game_id) do
    platform_id = format_platform_id(platform_id)

    path =
      "/observer-mode/rest/consumer/getGameMetaData/#{platform_id}/#{game_id}/1/token"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        Jason.decode(body)

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  def fetch_last_chunk_info(client, platform_id, game_id) do
    platform_id = format_platform_id(platform_id)

    path =
      "/observer-mode/rest/consumer/getLastChunkInfo/#{platform_id}/#{game_id}/0/token"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        Jason.decode(body)

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  def fetch_game_data_chunk(client, platform_id, game_id, chunk_id) do
    platform_id = format_platform_id(platform_id)

    path =
      "/observer-mode/rest/consumer/getGameDataChunk/#{platform_id}/#{game_id}/#{chunk_id}/token"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  def fetch_key_frame(client, platform_id, game_id, keyframe_id) do
    platform_id = format_platform_id(platform_id)

    path =
      "/observer-mode/rest/consumer/getKeyFrame/#{platform_id}/#{game_id}/#{keyframe_id}/token"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  # The platform_id should be uppercase ex: KR, EUW1
  defp format_platform_id(platform_id) do
    platform_id
    |> to_string()
    |> String.upcase()
  end
end
