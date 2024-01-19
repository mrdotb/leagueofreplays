defmodule LorWeb.SpectateModalComponent do
  @moduledoc false
  use LorWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:state, "windows")
      |> assign(:mac_script, LorWeb.ScriptHelpers.mac_script(assigns.spectate_params))

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

  defp show_windows(id) do
    JS.hide(to: "#tabpanel-mac-#{id}")
    |> JS.show(to: "#tabpanel-windows-#{id}")
    |> JS.push("windows")
  end

  defp show_mac(id) do
    JS.hide(to: "#tabpanel-windows-#{id}")
    |> JS.show(to: "#tabpanel-mac-#{id}")
    |> JS.push("mac")
  end
end
