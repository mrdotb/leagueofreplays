defmodule LorSpectator.SessionNotFoundError do
  defexception [:message, plug_status: 422]
end
