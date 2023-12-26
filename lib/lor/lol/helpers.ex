defmodule Lor.Lol.Helpers do
  @moduledoc """
  Helpers related to the Lol API.
  """

  @doc """
  Given a platform_id atom and a game_id compute the match_id
  """
  def get_match_id(platform_id, game_id) do
    platform_id =
      platform_id
      |> to_string()
      |> String.upcase()

    "#{platform_id}_#{game_id}"
  end
end
