defmodule LorWeb.ScriptHelpers do
  @moduledoc """
  Helpers to work with scripts
  """

  @doc """
  Return the spectator_endpoint url given the endpoint name and platform_id if applicable.
  Support `lor`, `riot`.
  """
  def spectator_endpoint(endpoint, platform_id \\ nil)

  def spectator_endpoint("lor", _platform_id) do
    config = Application.fetch_env!(:lor, LorSpectator.Endpoint)[:url]
    "#{config[:host]}:#{config[:port]}"
  end

  def spectator_endpoint("riot", platform_id) do
    "spectator.#{platform_id}.lol.pvp.net:8080"
  end

  @doc """
  Return a bash script that can be used to launch the spectate of a game from
  a mac shell.
  """
  def mac_script(params) do
    spectator_endpoint = spectator_endpoint(params.endpoint, params.platform_id)
    platform_id = get_platform_id(:mac, params.endpoint, params.platform_id)

    """
    if test -d  /Applications/League\ of\ Legends.app/Contents/LoL/Game/ ; then cd /Applications/League\ of\ Legends.app/Contents/LoL/Game/ && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; else cd /Applications/League\ of\ Legends.app/Contents/LoL/RADS/solutions/lol_game_client_sln/releases/ && cd $(ls -1vr -d */ | head -1) && cd deploy && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; fi && riot_launched=true ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends "spectator #{spectator_endpoint} #{params.encryption_key} #{params.game_id} #{platform_id}" "-UseRads" "-GameBaseDir=.."
    """
  end

  @doc """
  Return the platform id for spectate script purpose.
  system can be :mac or :windows
  endpoint `lor` or `riot`
  """
  def get_platform_id(system, endpoint, platform_id)

  # Add session id for bash script
  def get_platform_id(:mac, "lor", platform_id) do
    platform_id = format_platform_id(platform_id)
    "#{platform_id}-$RANDOM$RANDOM"
  end

  # Add session id for bat script
  def get_platform_id(:windows, "lor", platform_id) do
    platform_id = format_platform_id(platform_id)
    "#{platform_id}-%RANDOM%%RANDOM%"
  end

  def get_platform_id(system, "riot", platform_id) when system in [:mac, :windows] do
    format_platform_id(platform_id)
  end

  defp format_platform_id(platform_id), do: platform_id |> to_string() |> String.upcase()
end
