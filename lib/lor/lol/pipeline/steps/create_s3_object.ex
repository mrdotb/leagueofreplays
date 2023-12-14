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
    bucket = "original"
    key = "matches/#{match_id}.json"
    binary_json = Jason.encode!(match_data)

    params = %{
      bucket: bucket,
      key: key,
      content_type: "application/json",
      file_name: "#{match_id}.json"
    }

    Lor.S3.Object.upload(binary_json, false, params)
  end

  @impl true
  def undo(s3_object, _arguments, _context, _options) do
    Lor.S3.Object.destroy(s3_object)
  end
end
