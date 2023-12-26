defmodule LorWeb.LolComponents do
  @moduledoc """
  Provides components related to league of legends.

  Champions, items, runes ...
  """
  use Phoenix.Component

  alias LorWeb.PetalComponents, as: PC

  attr :game_version, :string
  attr :champion_key, :integer
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg", "xl"])

  def champion(assigns) do
    img = Lor.Lol.Ddragon.get_champion_image(assigns.game_version, assigns.champion_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <PC.avatar src={@src} size={@size} />
    """
  end

  attr :game_version, :string
  attr :summoner_key, :integer

  def summoner(assigns) do
    img = Lor.Lol.Ddragon.get_summoner_image(assigns.game_version, assigns.summoner_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <div class="bg-gray-900 w-8 h-8 border border-gray-200 dark:border-gray-700">
      <img src={@src} class="w-full" />
    </div>
    """
  end

  attr :game_version, :string
  attr :item_key, :integer

  def item(assigns) do
    img = Lor.Lol.Ddragon.get_item_image(assigns.game_version, assigns.item_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <div class="bg-gray-900 w-8 h-8 border border-gray-200 dark:border-gray-700">
      <img src={@src} class="w-full" />
    </div>
    """
  end
end
