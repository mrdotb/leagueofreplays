defmodule Lor do
  @moduledoc """
  Lor keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def mac_script(spectator_endpoint, encryption_key, game_id, platform_id) do
    """
    if test -d  /Applications/League\ of\ Legends.app/Contents/LoL/Game/ ; then cd /Applications/League\ of\ Legends.app/Contents/LoL/Game/ && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; else cd /Applications/League\ of\ Legends.app/Contents/LoL/RADS/solutions/lol_game_client_sln/releases/ && cd $(ls -1vr -d */ | head -1) && cd deploy && chmod +x ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends ; fi && riot_launched=true ./LeagueofLegends.app/Contents/MacOS/LeagueofLegends "spectator #{spectator_endpoint} #{encryption_key} #{game_id} #{platform_id}" "-UseRads" "-GameBaseDir=.."
    """
  end
end
