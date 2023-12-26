defmodule LorWeb.ReplayLive.MatchCardComponent do
  @moduledoc false
  use LorWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end
end
