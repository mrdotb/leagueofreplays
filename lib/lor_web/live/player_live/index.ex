defmodule LorWeb.PlayerLive.Index do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_offset, 0)
      |> assign(:page_limit, 10)
      |> assign(:pages, 0)
      |> assign(:active_page, 1)
      |> assign(:players, [])
      |> assign(:search, "")
      |> assign(:record, true)
      |> assign(:form, to_form(%{"record" => true}))

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
      |> assign_record(params)

    page = list_players(socket)

    socket
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:page, page)
    |> assign(:players, page.results)
  end

  @impl true
  def handle_event("search", %{"search" => search, "record" => record}, socket) do
    socket = push_patch(socket, to: ~p"/players?page=1&search=#{search}&record=#{record}")
    {:noreply, socket}
  end

  defp list_players(%{
         assigns: %{
           page_offset: page_offset,
           page_limit: page_limit,
           search: search,
           record: record
         }
       }) do
    page = [offset: page_offset, limit: page_limit, count: true]
    Lor.Pros.Player.list!(%{record: record, normalized_name: search}, page: page)
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

  defp assign_record(socket, %{"record" => record}) do
    record = if(record === "false", do: false, else: true)
    assign(socket, :record, record)
  end

  defp assign_record(socket, _), do: socket
end
