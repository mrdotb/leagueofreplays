defmodule LorWeb.ReplayLive.MatchCardComponent do
  @moduledoc false
  use LorWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:match, AsyncResult.loading())
      |> assign(:state, "replay")
      |> assign(:show_modal?, false)
      |> assign(:modal_state, "windows")
      |> assign(:mac_script, LorWeb.ScriptHelpers.mac_script(assigns.participant.match.replay))

    {:ok, socket}
  end

  def handle_event("replay", _params, socket) do
    socket =
      if socket.assigns.state != "replay" do
        assign(socket, :state, "replay")
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("post-game", _params, socket) do
    socket =
      if socket.assigns.state != "post-game" do
        assign(socket, :state, "post-game")
      else
        socket
      end

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

  def handle_event("show-modal", _params, socket) do
    socket =
      if socket.assigns.show_modal? do
        socket
      else
        assign(socket, show_modal?: true)
      end

    {:noreply, socket}
  end

  def handle_event("close_modal", _, socket) do
    socket =
      if socket.assigns.show_modal? do
        assign(socket, show_modal?: false)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("windows", _, socket) do
    socket =
      if socket.assigns.modal_state == "mac" do
        assign(socket, modal_state: "windows")
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("mac", _, socket) do
    socket =
      if socket.assigns.modal_state == "windows" do
        assign(socket, modal_state: "mac")
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

  defp pro_participant(assigns) do
    ~H"""
    <div
      role="button"
      tabIndex="0"
      phx-click={@click}
      class="grid-participants px-1 py-2 w-full hover:bg-gray-50 dark:hover:bg-gray-900"
    >
      <div class="[grid-area:creation] flex items-center justify-center ">
        <.time_ago id={@participant.id} datetime={@participant.match.game_start} />
      </div>

      <LOLC.player
        class="[grid-area:player]"
        src={@participant.summoner.player.picture.url}
        name={@participant.summoner.player.official_name}
      />

      <LOLC.versus
        class="[grid-area:versus]"
        game_version="12.12.1"
        champion_key={@participant.champion_id}
        opponent_champion_key={@participant.opponent_participant.champion_id}
      />

      <LOLC.kda
        class="[grid-area:kda]"
        kills={@participant.kills}
        deaths={@participant.deaths}
        assists={@participant.assists}
      />

      <LOLC.summoners
        class="[grid-area:summoners]"
        game_version="12.12.1"
        summoners={@participant.summoners}
      />

      <LOLC.build
        class="[grid-area:build] md:hidden lg:flex"
        game_version="12.12.1"
        items={@participant.items}
      />

      <div class="[grid-area:ellipsis] hidden lg:flex items-center">
        <.icon name="hero-ellipsis-horizontal" class="w-6 h-6" />
      </div>
    </div>
    """
  end

  defp post_match(assigns) do
    ~H"""
    <div :if={@match}>
      <%= for {participant, index} <- Enum.with_index(@match.participants, 1) do %>
        <div :if={index in [1, 6]} class="grid-team-participants-header px-1 py-1">
          <div class="[grid-area:side] flex space-x-1">
            <div class="text-red-400">Victory</div>
            <span :if={index == 1}>Blue side</span>
            <span :if={index == 6}>Red side</span>
          </div>
          <div class="[grid-area:summoners]">Summoners</div>
          <div class="[grid-area:kda] text-center">KDA</div>
          <div class="[grid-area:gold] text-center">Gold earned</div>
          <div class="[grid-area:build] text-center">Build</div>
        </div>

        <div class="grid-team-participants px-1 py-1">
          <div class="[grid-area:summoner-champion] flex items-center space-x-1">
            <LOLC.champion game_version="12.12.1" champion_key={participant.champion_id} />
            <.link :if={participant.summoner.player} class="hover:underline">
              <%= participant.summoner.player.official_name %>
            </.link>
            <span :if={is_nil(participant.summoner.player_id)}>
              <%= participant.summoner.name %>
            </span>
          </div>

          <LOLC.summoners
            class="[grid-area:summoners]"
            game_version="12.12.1"
            summoners={participant.summoners}
          />

          <LOLC.kda
            class="[grid-area:kda]"
            kills={participant.kills}
            deaths={participant.deaths}
            assists={participant.assists}
          />

          <div class="[grid-area:gold] text-center">
            <span class="text-yellow-600 dark:text-yellow-400">
              <%= participant.gold_earned %>
            </span>
          </div>

          <LOLC.build class="[grid-area:build]" game_version="12.12.1" items={participant.items} />
        </div>
      <% end %>
    </div>
    """
  end

  defp spectate_params(replay) do
    Map.take(replay, [:platform_id, :game_id, :encryption_key])
  end

  defp show_post_game(participant_id) do
    JS.hide(to: "#tabpanel-replay-#{participant_id}")
    |> JS.show(to: "#tabpanel-post-game-#{participant_id}")
    |> JS.push("post-game")
  end

  defp show_replay(participant_id) do
    JS.hide(to: "#tabpanel-post-game-#{participant_id}")
    |> JS.show(to: "#tabpanel-replay-#{participant_id}")
    |> JS.push("replay")
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
