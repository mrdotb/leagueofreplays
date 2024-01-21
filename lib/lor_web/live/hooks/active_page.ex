defmodule LorWeb.Hooks.ActivePage do
  @moduledoc """
  Using the uri add an active_page to the assigns.
  """

  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(opts, _params, _session, socket) do
    {:cont,
     attach_hook(socket, :active_page, :handle_params, &set_current_page(&1, &2, &3, opts))}
  end

  defp set_current_page(_params, uri, socket, _opts) do
    %URI{path: path} = URI.parse(uri)
    socket = assign(socket, :current_page, path)
    {:cont, socket}
  end
end
