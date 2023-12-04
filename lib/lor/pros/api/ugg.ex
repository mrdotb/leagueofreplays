defmodule Lor.Pros.UGG do
  @moduledoc """
  A thin wrapper around the pro-list.json endpoint of UGG
  """

  @url "https://stats2.u.gg/pro/pro-list.json"

  def list_pros do
    {:ok, %{body: body}} = Tesla.get(@url)

    body
    |> Jason.decode!()
    |> Enum.map(fn player ->
      Map.merge(player, %{
        "picture" => player_picture_url(player["normalized_name"]),
        "team_picture" => team_picture_url(player["current_team"])
      })
    end)
  end

  defp player_picture_url(normalized_name) do
    "https://static.bigbrain.gg/assets/probuildstats/player_images/small_2x/#{normalized_name}.png"
  end

  defp team_picture_url(team) do
    team =
      team
      |> String.replace(" ", "")
      |> String.downcase()

    "https://static.bigbrain.gg/assets/probuildstats/team_icons/#{team}.png"
  end
end
