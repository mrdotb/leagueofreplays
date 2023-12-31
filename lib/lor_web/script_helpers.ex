defmodule LorWeb.ScriptHelpers do
  @moduledoc """
  Helpers to work with scripts
  """

  def spectator_endpoint do
    config = Application.fetch_env!(:lor, LorSpectator.Endpoint)[:url]
    "#{config[:host]}:#{config[:port]}"
  end

  def mac_script(replay) do
    platform_id = replay.platform_id |> to_string() |> String.upcase()

    """
    if test -d  /Applications/League\ of\ Legends.app/Contents/LoL/Game/ ; then cd /Applications/League\ of\ Legends.app/Contents/LoL/Game/ && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; else cd /Applications/League\ of\ Legends.app/Contents/LoL/RADS/solutions/lol_game_client_sln/releases/ && cd $(ls -1vr -d */ | head -1) && cd deploy && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; fi && riot_launched=true ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends "spectator #{spectator_endpoint()} #{replay.encryption_key} #{replay.game_id} #{platform_id}-$RANDOM$RANDOM" "-UseRads" "-GameBaseDir=.."
    """
  end
end
