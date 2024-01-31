defmodule LorWeb.AdminLive.SummonerFormComponent do
  @moduledoc false
  use LorWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:form, to_form(%{}, as: "search"))
      |> assign(:game_version, Lor.Lol.Ddragon.get_last_game_version())
      |> assign(:platform_id, nil)
      |> assign(:platform_ids, Lor.Lol.PlatformIds.values())
      |> assign(:request, AsyncResult.ok(nil))
      |> assign(:state, "local")
      |> assign(:summoners, [])

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => %{"platform_id" => platform_id, "search" => search}},
        socket
      ) do
    platform_id = get_platform_id(platform_id)

    socket =
      socket
      |> assign(:platform_id, platform_id)
      |> assign(:search, search)
      |> assign_search()

    {:noreply, socket}
  end

  def handle_event("attach", %{"id" => id}, %{assigns: %{player_id: player_id}} = socket) do
    id
    |> Lor.Lol.Summoner.get!()
    |> Lor.Lol.Summoner.attach!(player_id)

    socket =
      socket
      |> assign_search()

    {:noreply, socket}
  end

  def handle_event("create-and-attach", _, socket) do
    platform_id = socket.assigns.platform_id
    region = Lor.Lol.PlatformIds.fetch_region!(platform_id)
    summoner_data = socket.assigns.request.result
    player_id = socket.assigns.player_id
    puuid = summoner_data["puuid"]

    with {:ok, account_data} <- Lor.Lol.Rest.fetch_account_by_puuid(region, puuid),
         {:ok, _summoner} <-
           Lor.Lol.Summoner.create_from_api(platform_id, summoner_data, account_data, player_id) do
      # TODO display success or failure
      nil
    end

    {:noreply, socket}
  end

  def handle_event("local", _params, socket) do
    socket =
      if socket.assigns.state == "api" do
        assign(socket, state: "local")
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("api", _params, socket) do
    socket =
      if socket.assigns.state == "local" do
        assign(socket, state: "api")
      else
        socket
      end

    {:noreply, socket}
  end

  defp assign_search(
         %{assigns: %{state: "local", platform_id: platform_id, search: search}} = socket
       ) do
    summoners = list_summoners!(platform_id, search)
    assign(socket, :summoners, summoners)
  end

  defp assign_search(
         %{assigns: %{state: "api", platform_id: platform_id, search: search}} = socket
       ) do
    if platform_id != nil and search != "" do
      socket
      |> assign(:request, AsyncResult.loading())
      |> assign_async(:request, fn ->
        case Lor.Lol.Rest.fetch_summoner_by_name(platform_id, search) do
          {:ok, data} ->
            {:ok, %{request: data}}

          {:error, error} ->
            {:error, error}
        end
      end)
    else
      socket
    end
  end

  defp get_platform_id(platform_id) do
    case Lor.Lol.PlatformIds.match(platform_id) do
      {:ok, platform_id} ->
        platform_id

      :error ->
        nil
    end
  end

  defp list_summoners!(nil, _search), do: []
  defp list_summoners!(_platform_id, ""), do: []

  defp list_summoners!(platform_id, search) when is_atom(platform_id) and is_binary(search) do
    filter = %{platform_id: platform_id, name: search}

    filter
    |> Lor.Lol.Summoner.list!()
    |> Lor.Lol.load!(:player)
  end

  defp show_local(id) do
    JS.hide(to: "#tabpanel-api-#{id}")
    |> JS.show(to: "#tabpanel-local-#{id}")
    |> JS.push("local")
  end

  defp show_api(id) do
    JS.hide(to: "#tabpanel-local-#{id}")
    |> JS.show(to: "#tabpanel-api-#{id}")
    |> JS.push("api")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <PC.tabs role="tablist" class="justify-center mb-4">
        <PC.tab
          id="summoner-local-search"
          role="tab"
          aria-selected={if(@state == "local", do: "true", else: "false")}
          aria-controls={"tabpanel-local-#{@id}"}
          tabindex={if(@state == "local", do: "1", else: "2")}
          is_active={@state == "local"}
          phx-click={show_local(@id)}
          phx-target={@myself}
        >
          <.icon name="hero-circle-stack" class="w-6 h-6 mr-2" />
          <span>Local</span>
        </PC.tab>
        <PC.tab
          id="summoner-api-search"
          role="tab"
          aria-selected={if(@state == "api", do: "true", else: "false")}
          aria-controls={"tabpanel-api-#{@id}"}
          tabindex={if(@state == "api", do: "1", else: "2")}
          is_active={@state == "api"}
          phx-click={show_api(@id)}
          phx-target={@myself}
        >
          <.icon name="hero-globe-alt" class="w-6 h-6 mr-2" />
          <span>Riot Api</span>
        </PC.tab>
      </PC.tabs>

      <.form for={@form} phx-change="search" phx-submit="search" phx-target={@myself}>
        <PC.field
          required
          type="select"
          field={@form[:platform_id]}
          options={@platform_ids}
          prompt="Select platform"
        />

        <PC.field
          wrapper_class={[if(is_nil(@platform_id), do: "hidden")]}
          required
          field={@form[:search]}
          placeholder="hide on bush"
          phx-debounce="500"
          label="Search summoner"
        />
      </.form>

      <div id={"tabpanel-local-#{@id}"} class={[if(@state == "api", do: "hidden")]}>
        <div
          :if={length(@summoners) == 0 and @platform_id != nil and @search != ""}
          class="mt-4 flex items-center justify-center"
        >
          <div class="flex flex-col items-center">
            <.icon name="hero-exclamation-circle" class="w-12 h-12" />
            <p>Could not find any Summoners locally.</p>
          </div>
        </div>

        <PC.table :if={length(@summoners) > 0}>
          <PC.tr>
            <PC.th>Name</PC.th>
            <PC.th>Riot ID</PC.th>
            <PC.th>Current Player</PC.th>
            <PC.th>Actions</PC.th>
          </PC.tr>
          <PC.tr :for={summoner <- @summoners} id={summoner.id}>
            <PC.td class="flex items-center space-x-2">
              <LOLC.profile_icon
                assets_version={@game_version}
                icon_key={summoner.profile_icon_id}
                class="w-12 h-12 rounded-md overflow-hidden"
              />
              <span><%= summoner.name %></span>
            </PC.td>
            <PC.td>
              <%= summoner.riot_id %>
            </PC.td>
            <PC.td>
              <%= if(summoner.player) do %>
                <%= summoner.player.official_name %>
              <% end %>
            </PC.td>
            <PC.td>
              <PC.button size="xs" phx-click="attach" phx-target={@myself} phx-value-id={summoner.id}>
                Attach
              </PC.button>
            </PC.td>
          </PC.tr>
        </PC.table>
      </div>

      <div id={"tabpanel-api-#{@id}"} class={[if(@state == "local", do: "hidden")]}>
        <.async_result :let={request} assign={@request}>
          <:loading>
            <div class="flex items-center justify-center py-2">
              <PC.spinner size="md" />
            </div>
          </:loading>

          <:failed :let={_reason}>Could not find summoner name on riot api.</:failed>

          <PC.table :if={is_map(request)}>
            <PC.tr>
              <PC.th>Name</PC.th>
              <PC.th>Level</PC.th>
              <PC.th>Last update</PC.th>
              <PC.th>Actions</PC.th>
            </PC.tr>
            <PC.tr>
              <PC.td class="flex items-center space-x-2">
                <LOLC.profile_icon
                  assets_version={@game_version}
                  icon_key={request["profileIconId"]}
                  class="w-12 h-12 rounded-md overflow-hidden"
                />
                <span><%= request["name"] %></span>
              </PC.td>
              <PC.td>
                <%= request["summonerLevel"] %>
              </PC.td>
              <PC.td>
                <%= Lor.TimeHelpers.unix_timestamp_to_datetime(request["revisionDate"]) %>
              </PC.td>
              <PC.td>
                <PC.button size="xs" phx-click="create-and-attach" phx-target={@myself}>
                  Create and Attach
                </PC.button>
              </PC.td>
            </PC.tr>
          </PC.table>
        </.async_result>
      </div>
    </div>
    """
  end
end
