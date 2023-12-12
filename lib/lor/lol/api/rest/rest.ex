defmodule Lor.Lol.Rest do
  @moduledoc """
  Wrap the league api client in a call to preserve the request order.
  """
  use GenServer

  require Logger

  @timeout :infinity

  # Public API

  def start_link({route, name}) do
    GenServer.start_link(__MODULE__, route, name: name)
  end

  def list_matches(region, puuid, start \\ 0) do
    pid = get_pid(region)
    GenServer.call(pid, {:list_matches, puuid, start}, @timeout)
  end

  def fetch_match(region, match_id) do
    pid = get_pid(region)
    GenServer.call(pid, {:fetch_match, match_id}, @timeout)
  end

  def fetch_match_timeline(region, match_id) do
    pid = get_pid(region)
    GenServer.call(pid, {:fetch_match, match_id}, @timeout)
  end

  def fetch_summoner_by_name(platform_id, summoner_name) do
    pid = get_pid(platform_id)
    GenServer.call(pid, {:fetch_summoner_by_name, summoner_name}, @timeout)
  end

  def fetch_summoner_by_puuid(platform_id, puuid) do
    pid = get_pid(platform_id)
    GenServer.call(pid, {:fetch_summoner_by_puuid, puuid}, @timeout)
  end

  def fetch_league(platform_id, encrypted_id) do
    pid = get_pid(platform_id)
    GenServer.call(pid, {:fetch_league, encrypted_id}, @timeout)
  end

  def fetch_active_game_by_summoners(platform_id, encrypted_id) do
    pid = get_pid(platform_id)
    GenServer.call(pid, {:fetch_active_game_by_summoners, encrypted_id}, @timeout)
  end

  def fetch_account_by_puuid(region, puuid) do
    pid = get_pid(region)
    GenServer.call(pid, {:fetch_account_by_puuid, puuid}, @timeout)
  end

  def fetch_featured_game(region) do
    pid = get_pid(region)
    GenServer.call(pid, :fetch_featured_game, @timeout)
  end

  # Callbacks
  def init(route) do
    client = Lor.Lol.Rest.Client.new(route)
    {:ok, client}
  end

  def handle_call({:list_matches, puuid, start}, _from, client) do
    res = Lor.Lol.Rest.Client.list_matches(client, puuid, start)
    {:reply, res, client}
  end

  def handle_call({:fetch_match, match_id}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_match(client, match_id)
    {:reply, res, client}
  end

  def handle_call({:fetch_match_timeline, match_id}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_match_timeline(client, match_id)
    {:reply, res, client}
  end

  def handle_call({:fetch_summoner_by_name, summoner_name}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_summoner_by_name(client, summoner_name)
    {:reply, res, client}
  end

  def handle_call({:fetch_summoner_by_puuid, puuid}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_summoner_by_puuid(client, puuid)
    {:reply, res, client}
  end

  def handle_call({:fetch_league, encrypted_id}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_league(client, encrypted_id)
    {:reply, res, client}
  end

  def handle_call({:fetch_active_game_by_summoners, encrypted_id}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_active_game_by_summoners(client, encrypted_id)
    {:reply, res, client}
  end

  def handle_call({:fetch_account_by_puuid, puuid}, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_account_by_puuid(client, puuid)
    {:reply, res, client}
  end

  def handle_call(:fetch_featured_game, _from, client) do
    res = Lor.Lol.Rest.Client.fetch_featured_game(client)
    {:reply, res, client}
  end

  # Private
  defp get_pid(route) do
    name = "client:#{to_string(route)}"
    [{pid, _}] = Registry.lookup(Lor.Lol.Rest.Registry, name)
    pid
  end
end
