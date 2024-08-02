defmodule Lor.Discord.Logger do
  @moduledoc """
  Simple logger backend that sends logs to a Discord channel.
  """
  @behaviour :gen_event

  @default_format "$time $metadata[$level] $message\n"

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event(
        {level, _gl, {Logger, msg, ts, md}},
        %{level: min_level} =
          state
      ) do
    if (is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt) and
         not metadata_reject(md) do
      log_event(level, msg, ts, md, state)
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    # We're not buffering anything so this is a no-op
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  ## Helpers

  defp metadata_reject(md) do
    # Silence info logs from Phoenix
    if md[:application] == :phoenix and md[:erl_level] == :info do
      true
    else
      false
    end
  end

  defp log_event(
         level,
         msg,
         ts,
         md,
         %{discord_client: client, channel_info: channel_info, channel_error: channel_error} =
           state
       ) do
    case level do
      :info ->
        event = format_event(level, msg, ts, md, state)
        Lor.Discord.Client.post_message(client, channel_info, event)

      :error ->
        event = format_event(level, msg, ts, md, state)
        Lor.Discord.Client.post_message(client, channel_error, event)

      _other ->
        nil
    end

    {:ok, state}
  end

  defp format_event(level, msg, ts, md, %{
         info_format: info_format,
         error_format: error_format,
         metadata: keys
       }) do
    format =
      case level do
        :info -> info_format
        :error -> error_format
      end

    event = Logger.Formatter.format(format, level, msg, ts, take_metadata(md, keys))

    IO.iodata_to_binary(event)
  end

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    metadatas =
      Enum.reduce(keys, [], fn key, acc ->
        case Keyword.fetch(metadata, key) do
          {:ok, val} -> [{key, val} | acc]
          :error -> acc
        end
      end)

    Enum.reverse(metadatas)
  end

  defp configure(name, opts) do
    state = %{
      name: nil,
      info_format: nil,
      error_format: nil,
      level: nil,
      metadata: nil,
      channel_info: nil,
      channel_error: nil,
      discord_client: nil
    }

    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    metadata = Keyword.get(opts, :metadata, [])
    info_format_opts = Keyword.get(opts, :info_format, @default_format)
    error_format_opts = Keyword.get(opts, :error_format, @default_format)
    info_format = Logger.Formatter.compile(info_format_opts)
    error_format = Logger.Formatter.compile(error_format_opts)
    channel_info = Keyword.get(opts, :channel_info)
    channel_error = Keyword.get(opts, :channel_error)

    %{
      state
      | name: name,
        info_format: info_format,
        error_format: error_format,
        level: level,
        metadata: metadata,
        channel_info: channel_info,
        channel_error: channel_error,
        discord_client: Lor.Discord.Client.new()
    }
  end
end
