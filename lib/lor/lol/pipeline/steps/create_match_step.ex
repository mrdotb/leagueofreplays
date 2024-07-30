defmodule Lor.Lol.CreateMatchStep do
  @moduledoc "Run the create match flow"
  use Reactor.Step

  require Logger

  @impl true
  def run(arguments, _context, _options) do
    platform_id = arguments.platform_id
    match_data = arguments.match_data
    s3_object = arguments.s3_object

    %{
      summoners_to_create: summoners_to_create,
      existing_summoners: existing_summoners
    } = arguments.summoners_data

    ressources = [
      Lor.Lol.Match,
      Lor.Lol.Summoner,
      Lor.Lol.Participant
    ]

    Ash.DataLayer.transaction(
      ressources,
      fn ->
        with {:ok, create_match} <- Lor.Lol.Match.create_from_api(match_data, s3_object.id),
             {:ok, created_summoners} <- create_summoners(summoners_to_create, platform_id),
             {:ok, participants} <-
               create_participants(
                 match_data,
                 create_match,
                 created_summoners,
                 existing_summoners
               ),
             {:ok, updated_participants} <- update_opponent_participants(participants) do
          %{
            valid?: true,
            complete?: true,
            create_match: create_match,
            created_summoners: created_summoners,
            participants: updated_participants
          }
        else
          {:error, reason} -> Ash.DataLayer.rollback(ressources, reason)
        end
      end
    )
  end

  defp create_summoners(summoners_to_create, platform_id) do
    Enum.reduce_while(summoners_to_create, {:ok, []}, fn %{
                                                           summoner_data: summoner_data,
                                                           account_data: account_data
                                                         },
                                                         {:ok, acc} ->
      case Lor.Lol.Summoner.create_from_api(
             platform_id,
             summoner_data,
             account_data,
             nil
           ) do
        {:ok, summoner} ->
          {:cont, {:ok, [summoner | acc]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp create_participants(match_data, create_match, created_summoners, existing_summoners) do
    Enum.reduce_while(match_data["info"]["participants"], {:ok, []}, fn participant_data,
                                                                        {:ok, acc} ->
      case Lor.Lol.Participant.create_from_api(
             participant_data,
             existing_summoners,
             created_summoners,
             %{match_id: create_match.id}
           ) do
        {:ok, participant} ->
          {:cont, {:ok, [participant | acc]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp update_opponent_participants(participants) do
    Enum.reduce_while(participants, {:ok, []}, fn participant, {:ok, acc} ->
      case Lor.Lol.Participant.update_opponent_participant(participant, participants) do
        {:ok, updated_participant} ->
          {:cont, {:ok, [updated_participant | acc]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end
end
