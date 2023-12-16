defmodule Lor.Lol.Replays.Download do
  @moduledoc """
  Helper module to deal with the downloading part
  """

  require Logger

  @bucket "replays"

  def fetch_and_store_game_data_chunk(%{
        worker_pid: worker_pid,
        platform_id: platform_id,
        replay_id: replay_id,
        game_id: game_id,
        chunk_id: chunk_id
      }) do
    params = %{
      bucket: @bucket,
      key: "#{platform_id}/#{game_id}/game_data_chunks/#{chunk_id}",
      content_type: "application/octet-stream",
      file_name: to_string(chunk_id)
    }

    with {:ok, chunk} <- Lor.Lol.Observer.fetch_game_data_chunk(platform_id, game_id, chunk_id),
         {:ok, object} <- Lor.S3.Object.upload(chunk, false, params),
         {:ok, _chunk} <-
           Lor.Lol.Chunk.create(%{
             replay_id: replay_id,
             data_id: object.id,
             number: chunk_id
           }) do
      send(worker_pid, {:update_chunk_status, chunk_id, :downloaded})
    else
      {:error, :not_found} ->
        send(worker_pid, {:update_chunk_status, chunk_id, :missing})

      {:error, error} ->
        Logger.error("Replay Download fetch_and_store_game_data_chunk error #{inspect(error)}")
        send(worker_pid, {:update_chunk_status, chunk_id, :missing})
    end
  end

  def fetch_and_store_key_frame(%{
        worker_pid: worker_pid,
        platform_id: platform_id,
        replay_id: replay_id,
        game_id: game_id,
        key_frame_id: key_frame_id
      }) do
    params = %{
      bucket: @bucket,
      key: "#{platform_id}/#{game_id}/key_frames/#{key_frame_id}",
      content_type: "application/octet-stream",
      file_name: to_string(key_frame_id)
    }

    with {:ok, key_frame} <- Lor.Lol.Observer.fetch_key_frame(platform_id, game_id, key_frame_id),
         {:ok, object} <- Lor.S3.Object.upload(key_frame, false, params),
         {:ok, _key_frame} <-
           Lor.Lol.KeyFrame.create(%{
             replay_id: replay_id,
             data_id: object.id,
             number: key_frame_id
           }) do
      send(worker_pid, {:update_key_frame_status, key_frame_id, :downloaded})
    else
      {:error, :not_found} ->
        send(worker_pid, {:update_key_frame_status, key_frame_id, :missing})

      {:error, error} ->
        Logger.error("Replay Download fetch_and_store_key_frame error #{inspect(error)}")
    end
  end
end
