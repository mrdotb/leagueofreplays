defmodule LorWeb.SpectateModalComponent do
  @moduledoc false
  use LorWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:state, "windows")
      |> assign(:mac_script, LorWeb.ScriptHelpers.mac_script(assigns.participant.match.replay))

    {:ok, socket}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, socket}
  end

  def handle_event("windows", _, socket) do
    socket =
      if socket.assigns.state == "mac" do
        assign(socket, state: "windows")
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("mac", _, socket) do
    socket =
      if socket.assigns.state == "windows" do
        assign(socket, state: "mac")
      else
        socket
      end

    {:noreply, socket}
  end

  defp spectate_params(replay) do
    Map.take(replay, [:platform_id, :game_id, :encryption_key])
  end

  defp show_windows(participant_id) do
    JS.hide(to: "#tabpanel-mac-#{participant_id}")
    |> JS.show(to: "#tabpanel-windows-#{participant_id}")
    |> JS.push("windows")
  end

  defp show_mac(participant_id) do
    JS.hide(to: "#tabpanel-windows-#{participant_id}")
    |> JS.show(to: "#tabpanel-mac-#{participant_id}")
    |> JS.push("mac")
  end
end
