defmodule Lor.Lol.Replay.Changes.CreateFromApi do
  @moduledoc """
  Map the game_meta_data to our representation of replay.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    IO.inspect(changeset)
    game_meta_data = changeset.attributes.game_meta_data
    # "gameKey": {
    #   "gameId": 6720928471,
    #   "platformId": "EUW1"
    # },
    # game_id = 
    # params = %{
    #   game_id: state.game_id,
    #   platform_id: state.platform_id,
    #   encryption_key: state.active_game["observers"]["encryptionKey"]
    # }
    encryption_key = changeset.attributes.changeset
  end
end
