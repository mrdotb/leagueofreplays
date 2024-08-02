defmodule Lor.Discord.Client do
  @moduledoc """
  Discord http client
  """

  @doc """
  Create a client
  """
  def new do
    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://discord.com/api/v10"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"authorization", "Bot #{get_token()}"}]}
    ]

    Tesla.client(middlewares)
  end

  @doc """
  Post a message to a channel
  See ref https://discord.com/developers/docs/resources/channel#create-message
  Discord message is limited to max 2000 characters so if the message is longer
  than that we need to split it in batches.
  """
  def post_message(client, channel_id, message) do
    url = "/channels/#{channel_id}/messages"

    message
    |> String.codepoints()
    |> Enum.chunk_every(2000)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(fn message ->
      body = %{"content" => message}
      Tesla.post(client, url, body)
    end)
  end

  defp get_token do
    Application.get_env(:lor, __MODULE__)[:token]
  end
end
