defmodule Lor.Pros.Team.Changes.Update do
  @moduledoc """
  Handle the update of a team.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.before_transaction(&handle_before_transaction/2)
    |> Ash.Changeset.after_transaction(&handle_after_transaction/3)
  end

  defp handle_before_transaction(changeset, _context) do
    changeset
    |> Ash.Changeset.put_context(:logo_id, changeset.data.logo_id)
    |> Ash.Changeset.put_context(:logo, changeset.data.logo)
  end

  defp handle_after_transaction(
         %{context: %{logo_id: logo_id, logo: logo}},
         {:ok, team},
         _context
       )
       when is_binary(logo_id) do
    if logo_id != team.logo_id do
      Lor.S3.Object.destroy!(logo)
    end

    {:ok, team}
  end

  defp handle_after_transaction(_changeset, success_or_error_result, _context) do
    success_or_error_result
  end
end
