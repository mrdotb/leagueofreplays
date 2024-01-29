defmodule LorWeb.Formatter do
  @moduledoc """
  This module defines some function to help formatting.
  """

  @doc """
  Transform the atom send by `Phoenix.LiveView.Helpers.upload_errors/2` to a
  translatable error.
  """
  def upload_error(atom)

  def upload_error(:too_large) do
    Gettext.dgettext(LorWeb.Gettext, "errors", "Too large")
  end

  def upload_error(:too_many_files) do
    Gettext.dgettext(LorWeb.Gettext, "errors", "You have selected too many files")
  end

  def upload_error(:not_accepted) do
    Gettext.dgettext(
      LorWeb.Gettext,
      "errors",
      "You have selected an unacceptable file type"
    )
  end

  def upload_error(:external_client_failure) do
    Gettext.dgettext(
      LorWeb.Gettext,
      "errors",
      "Unknow error please retry later"
    )
  end

  def format_kb(byte) do
    kb =
      byte
      |> Decimal.div(1024)
      |> Decimal.round(1)

    "#{kb} kB"
  end
end
