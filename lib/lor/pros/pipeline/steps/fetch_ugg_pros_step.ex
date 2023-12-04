defmodule Lor.Pros.FetchUGGProsStep do
  @moduledoc """
  """
  use Reactor.Step

  @impl true
  def run(arguments, _context, _options) do
    platform_id = arguments.platform_id

    pros =
      Lor.Pros.UGG.list_pros()
      |> Enum.filter(fn ugg_pro ->
        # ugg name is wrong their region_id is platform_id
        platform_id == String.to_existing_atom(ugg_pro["region_id"])
      end)

    {:ok, pros}
  end
end
