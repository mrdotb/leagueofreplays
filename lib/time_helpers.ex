defmodule Lor.TimeHelpers do
  @moduledoc """
  Helpers function related with time.
  """

  def started_less_than_m_ago?(time, minutes)

  def started_less_than_m_ago?(unix_time, minutes) when is_integer(unix_time) do
    date_time = DateTime.from_unix!(unix_time, :millisecond)
    started_less_than_m_ago?(date_time, minutes)
  end

  def started_less_than_m_ago?(%DateTime{} = date_time, minutes) do
    now = DateTime.utc_now()
    DateTime.diff(now, date_time, :minute) < minutes
  end

  @doc """
  Convert a unix timestamp to datetime.
  """
  def unix_timestamp_to_datetime(unix_timestamp) do
    unix_timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.truncate(:second)
  end
end
