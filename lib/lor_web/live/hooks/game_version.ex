defmodule LorWeb.Hooks.GameVersion do
  @moduledoc """
  Add the current game version to the assigns.
  """

  import Phoenix.Component

  def on_mount(_opts, _params, _session, socket) do
    {:cont, assign_new(socket, :game_version, fn -> Lor.Lol.Ddragon.get_last_game_version() end)}
  end
end
