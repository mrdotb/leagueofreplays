defmodule LorWeb.LolComponents do
  @moduledoc """
  Provides components related to league of legends.

  Player, Champion, item, rune ...
  """
  use Phoenix.Component

  alias LorWeb.PetalComponents, as: PC

  attr :picture, :map
  attr :class, :string, default: "", doc: "CSS class"
  attr :name, :string, required: true

  def player(assigns) do
    ~H"""
    <div class={["flex items-center space-x-2", @class]}>
      <PC.avatar
        class="bg-gray-100 dark:bg-gray-700"
        size="md"
        src={if(@picture, do: @picture.url, else: false)}
      />
      <span class="hover:underline">
        <%= @name %>
      </span>
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :champion_key, :integer, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def champion(assigns) do
    img = Lor.Lol.Ddragon.get_champion_image(assigns.assets_version, assigns.champion_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <div class={@class}>
      <img src={@src} class="w-full" />
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :summoner_key, :integer, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def summoner(assigns) do
    img = Lor.Lol.Ddragon.get_summoner_image(assigns.assets_version, assigns.summoner_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <div class="h-8 w-8 border border-gray-200 bg-gray-900 dark:border-gray-700">
      <img src={@src} class="w-full" />
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :item_key, :integer, required: true

  def item(assigns) do
    img = Lor.Lol.Ddragon.get_item_image(assigns.assets_version, assigns.item_key)
    assigns = assign(assigns, src: img)

    ~H"""
    <div class="h-8 w-8 border border-gray-200 bg-gray-900 dark:border-gray-700">
      <img src={@src} class="w-full" />
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :champion_key, :integer, required: true
  attr :opponent_champion_key, :integer, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def versus(assigns) do
    ~H"""
    <div class={["flex items-center justify-center space-x-1", @class]}>
      <.champion
        class="w-8 h-8 rounded-full overflow-hidden"
        assets_version={@assets_version}
        champion_key={@champion_key}
      />
      <span class="text-xs">vs</span>
      <.champion
        class="w-8 h-8 rounded-full overflow-hidden"
        assets_version={@assets_version}
        champion_key={@opponent_champion_key}
      />
    </div>
    """
  end

  attr :kills, :integer, required: true
  attr :deaths, :integer, required: true
  attr :assists, :integer, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def kda(assigns) do
    ~H"""
    <div class={["flex items-center justify-center", @class]}>
      <span><%= @kills %></span>
      / <span class="text-red-400"><%= @deaths %></span>
      / <span><%= @assists %></span>
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :summoners, :list, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def summoners(assigns) do
    ~H"""
    <div class={["flex items-center justify-center space-x-1", @class]}>
      <.summoner
        :for={summoner_key <- @summoners}
        assets_version={@assets_version}
        summoner_key={summoner_key}
      />
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :items, :list, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def build(assigns) do
    ~H"""
    <div class={["flex items-center justify-center space-x-0.5", @class]}>
      <.item :for={item_key <- @items} assets_version={@assets_version} item_key={item_key} />
    </div>
    """
  end

  attr :assets_version, :string, required: true
  attr :icon_key, :integer, required: true
  attr :class, :string, default: "", doc: "CSS class"

  def profile_icon(assigns) do
    ~H"""
    <div class={["border border-gray-200 bg-gray-900 dark:border-gray-700", @class]}>
      <img class="w-full" src={Lor.Lol.Ddragon.get_profile_icon(@assets_version, @icon_key)} />
    </div>
    """
  end
end
