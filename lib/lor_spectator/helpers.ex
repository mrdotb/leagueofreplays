defmodule LorSpectator.Helpers do
  @moduledoc """
  General helpers to work with lor spectator
  """

  @doc """
  Given params split the session_id from the platform_id and return a map with
  with the adjusted value
  """
  def add_session_params!(params) do
    with {:ok, platform_id_session_id_str} <- Map.fetch(params, "platform_id"),
         {:ok, data} <- fetch_platform_id_and_session_id(platform_id_session_id_str) do
      Map.merge(params, data)
    else
      :error ->
        raise LorSpectator.SessionNotFoundError, "Session was not found in the platform_id params"
    end
  end

  defp fetch_platform_id_and_session_id(platform_id_session_id_str) do
    case String.split(platform_id_session_id_str, "-", part: 2) do
      [platform_id, session_id] ->
        {:ok, %{"platform_id" => platform_id, "session_id" => session_id}}

      _ ->
        :error
    end
  end

  @doc """
  We don't need to serve all the chunk info like the offical server since we
  already have all the chunks and key_frames.
  Instead we serve the first chunk + keyframe we have and after the
  get_last_chunk_info is called n time on this particular session we return the
  last chunk info.
  """
  def get_last_chunk_info(replay, game_id, session_id) do
    if serve_last_chunk_info?(game_id, session_id) do
      get_last_chunk_info(replay.last_chunk_id, replay.last_key_frame_id)
    else
      get_first_chunk_info(replay.first_chunk_id, replay.first_key_frame_id)
    end
  end

  defp serve_last_chunk_info?(game_id, session_id) do
    cache_op =
      Cachex.get_and_update(:lor_spectator_cache, {game_id, session_id}, fn
        nil ->
          {:commit, 0, ttl: :timer.minutes(5)}

        count ->
          {:commit, count + 1}
      end)

    case cache_op do
      {:commit, _count, _opts} ->
        false

      {:commit, count} ->
        count > 3

      {:ignore, _count} ->
        false
    end
  end

  @doc """
  Given the first game_meta_data create the first chunk info
  """
  def get_first_chunk_info(first_chunk_id, first_key_frame_id) do
    %{
      "chunkId" => first_key_frame_id,
      "availableSince" => 30000,
      "nextAvailableChunk" => 10000,
      "keyFrameId" => first_key_frame_id,
      "nextChunkId" => first_chunk_id,
      "endStartupChunkId" => 1,
      "startGameChunkId" => 2,
      "endGameChunkId" => 0,
      "duration" => 30000
    }
  end

  def get_last_chunk_info(last_chunk_id, last_key_frame_id) do
    %{
      "availableSince" => 30000,
      "chunkId" => last_chunk_id,
      "duration" => 30000,
      "endGameChunkId" => last_chunk_id,
      "endStartupChunkId" => 1,
      "keyFrameId" => last_key_frame_id,
      "nextAvailableChunk" => 10000,
      "nextChunkId" => last_chunk_id,
      "startGameChunkId" => 2
    }
  end

  defp get_replay_bucket_url do
    config = Application.get_env(:lor, :s3)
    config[:replay][:url]
  end

  @doc """
  Get chunk url
  """
  def get_chunk_url(%{platform_id: platform_id, game_id: game_id, chunk_id: chunk_id}) do
    platform_id = String.downcase(platform_id)
    "#{get_replay_bucket_url()}/#{platform_id}/#{game_id}/game_data_chunks/#{chunk_id}"
  end

  @doc """
  Get key frame url
  """
  def get_key_frame_url(%{platform_id: platform_id, game_id: game_id, key_frame_id: key_frame_id}) do
    platform_id = String.downcase(platform_id)
    "#{get_replay_bucket_url()}/#{platform_id}/#{game_id}/key_frames/#{key_frame_id}"
  end
end
