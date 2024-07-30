defmodule LorWeb.AdminLive.Players do
  @moduledoc false
  use LorWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_offset, 0)
      |> assign(:page_limit, 8)
      |> assign(:pages, 0)
      |> assign(:active_page, 1)
      |> assign(:players, [])
      |> assign(:form, to_form(%{}))
      |> assign(:search, "")
      |> assign(:player_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket =
      socket
      |> assign_active_page(params)
      |> assign_page_offset(params)
      |> assign_search(params)

    page = list_players(socket)

    socket
    |> assign(:page, page)
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:players, page.results)
  end

  defp apply_action(socket, :new, _params) do
    socket
  end

  defp apply_action(socket, :edit, %{"player_id" => player_id}) do
    assign(socket, :player_id, player_id)
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    socket = push_patch(socket, to: ~p"/admin/players")
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Lor.Pros.Player.get!()
    |> Ash.destroy!()

    socket = push_patch(socket, to: ~p"/admin/players")
    {:noreply, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    socket = push_patch(socket, to: ~p"/admin/players?page=1&search=#{search}")
    {:noreply, socket}
  end

  defp list_players(%{
         assigns: %{page_offset: page_offset, page_limit: page_limit, search: search}
       }) do
    page = [offset: page_offset, limit: page_limit, count: true]
    Lor.Pros.Player.list!(%{normalized_name: search}, page: page)
  end

  defp assign_active_page(socket, %{"page" => page_params}) do
    case Integer.parse(page_params) do
      {active_page, _} -> assign(socket, :active_page, active_page)
      _ -> socket
    end
  end

  defp assign_active_page(socket, _params), do: socket

  defp assign_page_offset(
         socket = %{assigns: %{active_page: active_page, page_limit: page_limit}},
         _params
       ) do
    page_offset = (active_page - 1) * page_limit
    assign(socket, :page_offset, page_offset)
  end

  defp assign_search(socket, %{"search" => search}) do
    assign(socket, :search, search)
  end

  defp assign_search(socket, _), do: socket
end
