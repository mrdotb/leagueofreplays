defmodule LorWeb.AdminLive.SummonerFormComponent do
  @moduledoc false
  use LorWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:account_request, AsyncResult.ok(nil))
      |> assign(:form, to_form(%{}))
      |> assign(:game_name, "")
      |> assign(:platform_form, to_form(%{}))
      |> assign(:platform_id, nil)
      |> assign(:platform_ids, Lor.Lol.PlatformIds.values())
      |> assign(:search, "")
      |> assign(:state, "local")
      |> assign(:summoner_request, AsyncResult.ok(nil))
      |> assign(:summoners, [])
      |> assign(:tag_line, "")

    {:ok, socket}
  end

  @impl true
  def handle_event("change-platform", %{"platform_id" => platform_id}, socket) do
    platform_id = get_platform_id(platform_id)

    socket =
      socket
      |> assign(:platform_id, platform_id)
      |> assign(:platform_form, to_form(%{"platform_id" => platform_id}))

    {:noreply, socket}
  end

  def handle_event("validate", %{"game_name" => game_name, "tag_line" => tag_line}, socket) do
    socket = assign(socket, :form, to_form(%{"game_name" => game_name, "tag_line" => tag_line}))
    {:noreply, socket}
  end

  def handle_event("validate", %{"search" => search}, socket) do
    socket = assign(socket, :form, to_form(%{"search" => search}))
    {:noreply, socket}
  end

  def handle_event(
        "search",
        params,
        socket
      ) do
    socket =
      socket
      |> assign(:form, to_form(params))
      |> assign(:search, params["search"])
      |> assign(:game_name, params["game_name"])
      |> assign(:tag_line, params["tag_line"])
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

    {:noreply, put_flash!(socket, :success, "Summoner attached to player successfully!")}
  end

  def handle_event("create-and-attach-from-summoner", _, socket) do
    platform_id = socket.assigns.platform_id
    region = Lor.Lol.PlatformIds.fetch_region!(platform_id, :account)
    summoner_data = socket.assigns.summoner_request.result
    player_id = socket.assigns.player_id
    puuid = summoner_data["puuid"]

    with {:ok, account_data} <- Lor.Lol.Rest.fetch_account_by_puuid(region, puuid),
         {:ok, _summoner} <-
           Lor.Lol.Summoner.create_from_api(platform_id, summoner_data, account_data, player_id) do
      put_flash!(socket, :success, "Summoner created and attached to the player successfully!")
    else
      {:error, %{errors: [%{field: field}]}} when field in ~w(account_id riot_id)a ->
        put_flash!(socket, :error, "The summoner already exist attach it using local tab")

      _error ->
        put_flash!(socket, :error, "Unknow error")
    end

    {:noreply, socket}
  end

  def handle_event("create-and-attach-from-account", _, socket) do
    platform_id = socket.assigns.platform_id
    account_data = socket.assigns.account_request.result
    player_id = socket.assigns.player_id
    puuid = account_data["puuid"]

    with {:ok, summoner_data} <- Lor.Lol.Rest.fetch_summoner_by_puuid(platform_id, puuid),
         {:ok, _summoner} <-
           Lor.Lol.Summoner.create_from_api(platform_id, summoner_data, account_data, player_id) do
      put_flash!(socket, :success, "Summoner created and attached to the player successfully!")
    else
      {:error, %{errors: [%{field: field}]}} when field in ~w(account_id riot_id)a ->
        put_flash!(socket, :error, "The summoner already exist attach it using local tab")

      _error ->
        put_flash!(socket, :error, "Unknow error")
    end

    {:noreply, socket}
  end

  def handle_event("state", %{"state" => state}, socket) do
    socket =
      if socket.assigns.state == state do
        socket
      else
        assign(socket, :state, state)
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
         %{assigns: %{state: "summoner-api", platform_id: platform_id, search: search}} = socket
       ) do
    if platform_id != nil and search != "" do
      socket
      |> assign(:summoner_request, AsyncResult.loading())
      |> assign_async(:summoner_request, fn ->
        case Lor.Lol.Rest.fetch_summoner_by_name(platform_id, search) do
          {:ok, data} ->
            {:ok, %{summoner_request: data}}

          {:error, error} ->
            {:error, error}
        end
      end)
    else
      socket
    end
  end

  defp assign_search(
         %{
           assigns: %{
             state: "account-api",
             platform_id: platform_id,
             game_name: game_name,
             tag_line: tag_line
           }
         } = socket
       ) do
    if Enum.all?([platform_id, game_name, tag_line], &(not is_nil(&1) and &1 != "")) do
      socket
      |> assign(:account_request, AsyncResult.loading())
      |> assign_async(:account_request, fn ->
        region = Lor.Lol.PlatformIds.fetch_region!(platform_id, :account)

        case Lor.Lol.Rest.fetch_account_by_game_name_and_tag_line(region, game_name, tag_line) do
          {:ok, data} ->
            {:ok, %{account_request: data}}

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
    filter = %{platform_id: platform_id, search: search}

    filter
    |> Lor.Lol.Summoner.list!()
    |> Lor.Lol.load!(:player)
  end

  defp show_local(_id) do
    JS.push("state", value: %{state: "local"})
  end

  defp show_summoner_api(_id) do
    JS.push("state", value: %{state: "summoner-api"})
  end

  defp show_account_api(_id) do
    JS.push("state", value: %{state: "account-api"})
  end
end
