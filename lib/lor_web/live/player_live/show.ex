defmodule LorWeb.PlayerLive.Show do
  @moduledoc false
  use LorWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:player, get_player!(params))
      |> assign(:page_after, nil)
      |> assign(:page_before, nil)
      |> assign(:page_limit, 10)
      |> assign(:next_page, nil)
      |> assign(:prev_page, nil)
      |> assign(:participants, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket =
      socket
      |> assign_page_after(params)
      |> assign_page_before(params)

    page = list_participants(socket)

    socket
    |> assign_next_page(page)
    |> assign_prev_page(page)
    |> assign(:participants, page.results)
  end

  defp get_player!(%{"name" => name}) do
    name
    |> Lor.Pros.Player.by_normalized_name!()
    |> Ash.load!([:picture, current_team: :logo])
  end

  defp assign_next_page(socket, page) do
    case List.last(page.results) do
      last_record when is_struct(last_record) ->
        keyset = last_record.__metadata__.keyset
        assign(socket, next_page: keyset)

      nil ->
        socket
    end
  end

  defp assign_prev_page(socket, page) do
    case List.first(page.results) do
      first_record when is_struct(first_record) ->
        keyset = first_record.__metadata__.keyset
        assign(socket, prev_page: keyset)

      nil ->
        socket
    end
  end

  defp assign_page_after(socket, %{"after" => page_after}) do
    socket
    |> assign(:page_after, page_after)
    |> assign(:page_before, nil)
  end

  defp assign_page_after(socket, _), do: socket

  defp assign_page_before(socket, %{"before" => page_before}) do
    socket
    |> assign(:page_after, nil)
    |> assign(:page_before, page_before)
  end

  defp assign_page_before(socket, _), do: socket

  defp list_participants(%{
         assigns: %{player: player, page_limit: page_limit, page_after: nil, page_before: nil}
       }) do
    page = [limit: page_limit]
    Lor.Lol.Participant.list_replays!(%{player_id: player.id}, page: page)
  end

  defp list_participants(%{
         assigns: %{player: player, page_limit: page_limit, page_after: page_after}
       })
       when is_binary(page_after) do
    page = [limit: page_limit, after: page_after]
    Lor.Lol.Participant.list_replays!(%{player_id: player.id}, page: page)
  end

  defp list_participants(%{
         assigns: %{player: player, page_limit: page_limit, page_before: page_before}
       })
       when is_binary(page_before) do
    page = [limit: page_limit, before: page_before]
    Lor.Lol.Participant.list_replays!(%{player_id: player.id}, page: page)
  end
end
