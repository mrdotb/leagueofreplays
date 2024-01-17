defmodule LorWeb.ActiveGameLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}), active_games: list_active_games())
    {:ok, socket}
  end

  defp list_active_games do
    Lor.Lol.ActiveGame.list!(nil)
  end
end
