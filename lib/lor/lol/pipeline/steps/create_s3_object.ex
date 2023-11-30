defmodule Lor.Lol.CreateS3Object do
  @moduledoc """
  Upload the match data to s3 and create an object to track it in our local
  database.
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    match_data = arguments.match_data
    match_id = match_data["metadata"]["matchId"]
    binary_json = Jason.encode!(match_data)
    content_type = "application/json"
    md5 = Lor.S3.Utils.hash_bin_md5(binary_json)
    bucket = "original"
    key = "matches/#{match_id}.json"

    input = %{
      body: binary_json,
      content_type: content_type,
      md5: md5
    }

    object_params = %{
      bucket: bucket,
      key: key,
      file_name: "#{match_id}.json",
      content_type: content_type,
      md5: md5,
      size: byte_size(binary_json)
    }

    with {:ok, _response} <- Lor.S3.Api.put_object(bucket, key, input) do
      Lor.S3.Object.create(object_params)
    end
  end

  @impl true
  def undo(s3_object, _arguments, _context, _options) do
    with {:ok, _response} <- Lor.S3.Api.delete_object(s3_object.bucket, s3_object.key),
         {:ok, _s3_object} <- Lor.S3.Object.destroy(s3_object) do
      :ok
    end
  end
end
