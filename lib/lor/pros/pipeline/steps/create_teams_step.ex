defmodule Lor.Pros.CreateTeamsStep do
  @moduledoc """
  Create a team from UGG:
  - Try to download the team picture
  - Upload it to our S3
  - Create a S3 object
  - Create the team with a relation to the object
  """
  use Reactor.Step

  require Logger

  @impl true
  def run(arguments, _context, _options) do
    teams_to_create = arguments.teams_to_create

    teams = Enum.map(teams_to_create, &create_team/1)
    {:ok, teams}
  end

  defp create_team(team_data) do
    logo_id =
      case maybe_get_team_picture(team_data["team_picture"]) do
        {:ok, s3_object} -> s3_object.id
        {:error, _} -> nil
      end

    Lor.Pros.Team.create_from_ugg!(team_data, logo_id)
  end

  defp maybe_get_team_picture(team_picture_url) do
    case Tesla.get(team_picture_url) do
      {:ok, %{status: 200} = response} ->
        s3_upload_picture(response)

      _ ->
        {:error, :not_found}
    end
  end

  defp s3_upload_picture(response) do
    bucket = "pictures"
    file_name = Path.basename(response.url)
    key = "team/#{file_name}"
    md5 = Lor.S3.Utils.hash_bin_md5(response.body)
    content_type = Lor.S3.Utils.extract_content_type(response.headers)
    url = Lor.S3.Api.url(bucket, key)

    input = %{
      body: response.body,
      content_type: content_type,
      md5: md5
    }

    object_params = %{
      bucket: bucket,
      key: key,
      url: url,
      file_name: file_name,
      content_type: content_type,
      md5: md5,
      size: byte_size(response.body)
    }

    with {:ok, _response} <- Lor.S3.Api.put_object(bucket, key, input) do
      Lor.S3.Object.create(object_params)
    end
  end
end
