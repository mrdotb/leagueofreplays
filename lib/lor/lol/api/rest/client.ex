defmodule Lor.Lol.Rest.Client do
  @moduledoc """
  A thin wrapper around the rest riot api for the endpoint we are interested in.
  """

  require Logger

  @ranked_solo_game 420

  @platform_ids Lor.Lol.PlatformIds.values()
  @regions Lor.Lol.Regions.values()

  # Get token from config.
  defp token do
    Application.fetch_env!(:lor, __MODULE__)[:token]
  end

  @doc """
  Create a tesla client.
  """
  def new(region_or_platform_id) do
    middlewares = [
      # {Lor.Lol.Rest.RetryQueueMiddleware, region_or_platform_id},
      # this will make the request retry automatically when we hit the rate limit
      # and get a 429 status or the riot api return a 500 status
      {Tesla.Middleware.Retry,
       [
         delay: 10_000,
         max_retries: 20,
         max_delay: 60_000,
         should_retry: fn
           {:ok, %{status: status}} when status in [429, 503] -> true
           {:ok, _} -> false
           {:error, _} -> true
         end
       ]},
      # pass the riot token in header
      {Tesla.Middleware.Headers, [{"X-Riot-Token", token()}]},
      # set the BaseUrl depending what region endpoint we want to call
      {Tesla.Middleware.BaseUrl, url(region_or_platform_id)},
      # parse the JSON response automatically
      Tesla.Middleware.JSON,
      # Logger
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end

  # Depending on the endpoint we need to put a region or a platform_id
  # in some case we want the region who match the platform_id
  def url(region_or_platform_id)

  def url(region) when region in @regions do
    region =
      region
      |> to_string()
      |> String.downcase()

    "https://#{region}.api.riotgames.com"
  end

  def url(platform_id) when platform_id in @platform_ids do
    platform_id =
      platform_id
      |> to_string()
      |> String.downcase()

    "https://#{platform_id}.api.riotgames.com"
  end

  @doc """
  Given a client, puuid and optionnaly a start return a list of
  ranked_solo_game match ids.
  ## Example
    iex> RiotApi.list_matches(client, "8tjefad_ZLY2X8UbmwYlR1PBtaRgJBxcOcvFZ8tMy6f4bw56fMaIvLoqA87DK3yzqihZs7L-VQCdBw")
    ["EUW1_5794787018", "EUW1_5786706582", "EUW1_5777719214", "EUW1_5723851410",
     "EUW1_5630385359", "EUW1_5630305794", ...]
  """
  def list_matches(client, puuid, start \\ 0) do
    path = "/lol/match/v5/matches/by-puuid/#{puuid}/ids?"
    query = URI.encode_query(start: start, count: 100, queue: @ranked_solo_game)

    %{body: match_ids, status: 200} = Tesla.get!(client, path <> query)
    match_ids
  end

  @doc """
  Given a region and a match_id return a match_data.
  ## Example
    iex> RiotApi.fetch_match(:EUROPE, "EUW1_5794787018")
    {:ok,
      %{
        "info" => ...,
        "metadata" => ...
      }
    }
  """
  def fetch_match(client, match_id) do
    path = "/lol/match/v5/matches/#{match_id}"

    case Tesla.get!(client, path) do
      %{status: 200, body: match_data} ->
        {:ok, match_data}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a region client and a match_id return the match timeline.
  ## Example
    iex> RiotApi.fetch_match_timeline(client, "EUW1_5794787018")
    {:ok,
      %{
        "info" => ...,
        "metadata" => ...
      }
    }
  """
  def fetch_match_timeline(client, match_id) do
    path = "/lol/match/v5/matches/#{match_id}/timeline"

    case Tesla.get!(client, path) do
      %{status: 200, body: match_timeline} ->
        {:ok, match_timeline}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a platform_id client and a summoner_name get summoner_data
  ## Example
    iex> RiotApi.fetch_summoner_by_name(client, "godindatzotak")
    {:ok,
     %{
       "accountId" => "5H_Q0vPz0WFtt1mzOKicsavLEuYjLSDG-gNsKVBO4FjQBg",
       "id" => "2cNWTjUhUDNQlS-WEB1mIj6bePcdTxz17Gecw4RDQ90H4qA",
       "name" => "GodinDatZotak",
       "profileIconId" => 7,
       "puuid" => "8tjefad_ZLY2X8UbmwYlR1PBtaRgJBxcOcvFZ8tMy6f4bw56fMaIvLoqA87DK3yzqihZs7L-VQCdBw",
       "revisionDate" => 1660161403000,
       "summonerLevel" => 112
     }}
  """
  def fetch_summoner_by_name(client, summoner_name) do
    query = URI.encode_www_form(summoner_name)
    path = "/lol/summoner/v4/summoners/by-name/#{query}"

    res = Tesla.get!(client, path)

    case res do
      %{status: 200, body: summoner_data} ->
        {:ok, summoner_data}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a platform_id client and a puuid get summoner_data
  ## Example
    iex> RiotApi.fetch_summoner_by_puuid(client, "8tjefad_ZLY2X8UbmwYlR1PBtaRgJBxcOcvFZ8tMy6f4bw56fMaIvLoqA87DK3yzqihZs7L-VQCdBw")
    {:ok,
     %{
       "accountId" => "5H_Q0vPz0WFtt1mzOKicsavLEuYjLSDG-gNsKVBO4FjQBg",
       "id" => "2cNWTjUhUDNQlS-WEB1mIj6bePcdTxz17Gecw4RDQ90H4qA",
       "name" => "GodinDatZotak",
       "profileIconId" => 7,
       "puuid" => "8tjefad_ZLY2X8UbmwYlR1PBtaRgJBxcOcvFZ8tMy6f4bw56fMaIvLoqA87DK3yzqihZs7L-VQCdBw",
       "revisionDate" => 1660161403000,
       "summonerLevel" => 112
     }}
  """
  def fetch_summoner_by_puuid(client, puuid) do
    path = "/lol/summoner/v4/summoners/by-puuid/#{puuid}"

    case Tesla.get!(client, path) do
      %{status: 200, body: summoner_data} ->
        {:ok, summoner_data}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a platform_id client and a encrypted_summoner_id return
  the league data.
  """
  def fetch_league(client, encrypted_summoner_id) do
    path = "/lol/league/v4/entries/by-summoner/#{encrypted_summoner_id}"

    case Tesla.get!(client, path) do
      %{status: 200, body: league_entry} ->
        {:ok, league_entry}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a platform_id client and a encrypted_summoner_id return
  the active game.
  """
  def fetch_active_game_by_summoners(client, encrypted_summoner_id) do
    path = "/lol/spectator/v4/active-games/by-summoner/#{encrypted_summoner_id}"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 404} ->
        {:error, :no_active_game}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a client and a puuid fetch the account with gameName and tagLine.
  """
  def fetch_account_by_puuid(client, puuid) do
    path = "/riot/account/v1/accounts/by-puuid/#{puuid}"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 404} ->
        {:error, :not_found}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end

  @doc """
  Given a platform_id client get the featured game we can spectate.
  """
  def fetch_featured_game(client) do
    path = "/lol/spectator/v4/featured-games"

    case Tesla.get!(client, path) do
      %{status: 200, body: body} ->
        {:ok, body}

      other ->
        Logger.error(other)
        {:error, :unknow_error}
    end
  end
end
