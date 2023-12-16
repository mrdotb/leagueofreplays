defmodule LorSpectator do
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LorSpectator.Endpoint,
        router: LorSpectator.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
