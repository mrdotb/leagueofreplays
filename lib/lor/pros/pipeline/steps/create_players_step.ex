defmodule Lor.Pros.CreatePlayersStep do
  @moduledoc """
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    players_to_create = arguments.players_to_create
    existing_teams = arguments.existing_teams
    created_teams = arguments.created_teams
    teams_map = create_teams_map(existing_teams, created_teams)

    players =
      Enum.map(players_to_create, fn player_data ->
        create_player(teams_map, player_data)
      end)

    {:ok, players}
  end

  defp create_teams_map(existing_teams, created_teams) do
    existing_teams
    |> Kernel.++(created_teams)
    |> Enum.reduce(%{}, fn team, acc ->
      Map.put(acc, team.name, team)
    end)
  end

  defp create_player(teams_map, player_data) do
    picture_id =
      case maybe_get_player_picture(player_data["picture"]) do
        {:ok, s3_object} -> s3_object.id
        {:error, _} -> nil
      end

    current_team_id = Map.get(teams_map, player_data["current_team"]).id
    Lor.Pros.Player.create_from_ugg!(player_data, current_team_id, picture_id)
  end

  defp maybe_get_player_picture(picture_url) do
    case Tesla.get(picture_url) do
      {:ok, %{status: 200} = response} ->
        s3_upload_picture(response)

      _ ->
        {:error, :not_found}
    end
  end

  defp s3_upload_picture(response) do
    bucket = "pictures"
    file_name = Path.basename(response.url)
    key = "player/#{file_name}"
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
