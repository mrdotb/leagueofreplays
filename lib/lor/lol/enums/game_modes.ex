defmodule Lor.Lol.GameModes do
  @moduledoc """
  The game modes values from
  https://static.developer.riotgames.com/docs/lol/gameModes.json
  """
  use Ash.Type.Enum,
    values: [
      :classic,
      :odin,
      :aram,
      :tutorial,
      :urf,
      :doombotsteemo,
      :oneforall,
      :ascension,
      :firstblood,
      :kingporo,
      :siege,
      :assassinate,
      :arsr,
      :darkstar,
      :starguardian,
      :project,
      :gamemodex,
      :odyssey,
      :nexusblitz,
      :ultbook
    ]
end
