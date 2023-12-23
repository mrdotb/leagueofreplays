defmodule Lor.Lol.Ddragon.Client do
  @moduledoc """
  A thin wrapper around the ddragon api for the endpoint we are interested in
  """
  use Tesla, only: [:get]

  # TODO handle all locales
  @local "en_US"

  plug Tesla.Middleware.Retry
  plug Tesla.Middleware.BaseUrl, "https://ddragon.leagueoflegends.com"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  def fetch_champions(patch) do
    get("/cdn/#{patch}/data/#{@local}/champion.json")
  end

  def fetch_items(patch) do
    get("/cdn/#{patch}/data/#{@local}/item.json")
  end

  def fetch_summoners(patch) do
    get("/cdn/#{patch}/data/#{@local}/summoner.json")
  end

  def fetch_versions do
    get("/api/versions.json")
  end
end
