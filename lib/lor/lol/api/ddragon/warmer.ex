defmodule Lor.Lol.Ddragon.Warmer do
  @moduledoc """
  Warm the ddragon cache at startup and refresh every 24 hours.
  """
  use GenServer

  require Logger

  @interval :timer.hours(24)

  # Public API

  @doc "Start the Warmer"
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callbacks

  @impl true
  def init(_opts) do
    Logger.info("Start Ddragon Warmer")

    send(self(), :cache)
    {:ok, [], {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:cache, state) do
    champion_keys = get_champion_keys()
    Lor.Lol.Ddragon.Cache.put_all(champion_keys)

    summoner_keys = get_summoner_keys()
    Lor.Lol.Ddragon.Cache.put_all(summoner_keys)

    Process.send_after(self(), :cache, @interval)
    {:noreply, state}
  end

  defp get_champion_keys do
    with {:ok, %{body: versions}} <- Lor.Lol.Ddragon.Client.fetch_versions(),
         last_game_version <- List.first(versions),
         {:ok, %{body: champions_response}} <-
           Lor.Lol.Ddragon.Client.fetch_champions(last_game_version) do
      champions_img_list = get_champions_img_list(champions_response)
      champions_search_map = get_champions_search_map(champions_response)

      [{:champions_search_map, champions_search_map} | champions_img_list]
    end
  end

  defp get_champions_img_list(champions_response) do
    champions_response
    |> Map.get("data")
    |> Enum.map(fn {_champion_id, data} ->
      key = String.to_integer(data["key"])
      value = data["image"]["full"]
      {{:champion, key}, value}
    end)
  end

  defp get_champions_search_map(champions_response) do
    champions_response
    |> Map.get("data")
    |> Enum.map(fn {_champion_id, data} ->
      key = String.downcase(data["name"])
      value = String.to_integer(data["key"])
      {key, value}
    end)
    |> Map.new()
  end

  defp get_summoner_keys do
    with {:ok, %{body: versions}} <- Lor.Lol.Ddragon.Client.fetch_versions(),
         last_game_version <- List.first(versions),
         {:ok, %{body: summoners_response}} <-
           Lor.Lol.Ddragon.Client.fetch_summoners(last_game_version) do
      get_summoners_img_list(summoners_response)
    end
  end

  defp get_summoners_img_list(summoners_response) do
    summoners_response
    |> Map.get("data")
    |> Enum.map(fn {_summoner_id, data} ->
      key = String.to_integer(data["key"])
      value = data["image"]["full"]
      {{:summoner, key}, value}
    end)
  end
end
