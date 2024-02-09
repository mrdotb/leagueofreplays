defmodule LorWeb.Flash do
  import Phoenix.LiveView

  def on_mount(_name, _params, _session, socket) do
    {:cont, attach_hook(socket, :flash, :handle_info, &maybe_receive_flash/2)}
  end

  defp maybe_receive_flash({:put_flash, type, message}, socket) do
    {:halt, put_flash(socket, type, message)}
  end

  defp maybe_receive_flash(_, socket), do: {:cont, socket}

  def put_flash!(socket, type, message) do
    send(self(), {:put_flash, type, message})
    socket
  end
end
