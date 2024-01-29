defmodule LorWeb.AdminLive.Index do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
