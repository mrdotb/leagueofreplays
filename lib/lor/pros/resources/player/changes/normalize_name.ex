defmodule Lor.Pros.Player.Changes.NormalizeName do
  @moduledoc """
  Normalize official name.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    normalized_name =
      changeset
      |> Ash.Changeset.get_attribute(:official_name)
      |> normalize_name()

    Ash.Changeset.change_attribute(changeset, :normalized_name, normalized_name)
  end

  defp normalize_name(name) when is_binary(name) do
    name
    |> String.trim()
    |> String.downcase()
  end

  defp normalize_name(_name), do: nil
end
