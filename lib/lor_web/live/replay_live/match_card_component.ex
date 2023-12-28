defmodule LorWeb.ReplayLive.MatchCardComponent do
  @moduledoc false
  use LorWeb, :live_component

  require Ash.Sort

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:match, AsyncResult.loading())

    {:ok, socket}
  end

  def handle_event("load-match", _params, socket) do
    socket =
      if is_nil(socket.assigns.match.result) do
        assign_async(socket, :match, fn ->
          load_match(socket.assigns.participant.match)
        end)
      else
        socket
      end

    {:noreply, socket}
  end

  defp load_match(match) do
    participants_query =
      Lor.Lol.Participant
      |> Ash.Query.load([:team_position_order, summoner: :player])
      |> Ash.Query.sort([
        {:team_id, :asc},
        {:team_position_order, :asc}
      ])

    case Lor.Lol.load(match, participants: participants_query) do
      {:ok, match} ->
        {:ok, %{match: match}}

      {:error, error} ->
        {:ok, %{match: error}}
    end
  end
end
