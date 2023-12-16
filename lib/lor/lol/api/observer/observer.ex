defmodule Lor.Lol.Observer do
  @moduledoc """
  A small wrapper around observer client.
  """

  def fetch_api_version(platform_id) do
    client = Lor.Lol.Observer.Clients.get_client(platform_id)
    Lor.Lol.Observer.Client.fetch_api_version(client)
  end

  def fetch_game_meta_data(platform_id, game_id) do
    client = Lor.Lol.Observer.Clients.get_client(platform_id)
    Lor.Lol.Observer.Client.fetch_game_meta_data(client, platform_id, game_id)
  end

  def fetch_last_chunk_info(platform_id, game_id) do
    client = Lor.Lol.Observer.Clients.get_client(platform_id)
    Lor.Lol.Observer.Client.fetch_last_chunk_info(client, platform_id, game_id)
  end

  def fetch_game_data_chunk(platform_id, game_id, chunk_id) do
    client = Lor.Lol.Observer.Clients.get_client(platform_id)
    Lor.Lol.Observer.Client.fetch_game_data_chunk(client, platform_id, game_id, chunk_id)
  end

  def fetch_key_frame(platform_id, game_id, keyframe_id) do
    client = Lor.Lol.Observer.Clients.get_client(platform_id)
    Lor.Lol.Observer.Client.fetch_key_frame(client, platform_id, game_id, keyframe_id)
  end
end
