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
        with {:ok, create_match, match_notification} <-
               Lor.Lol.Match.create_from_api(match_data, s3_object.id,
                 return_notifications?: true
               ),
             {:ok, created_summoners, summoner_notifications} <-
               create_summoners(summoners_to_create, platform_id),
             {:ok, participants, created_participant_notifications} <-
               create_participants(
                 match_data,
                 create_match,
                 created_summoners,
                 existing_summoners
               ),
             {:ok, updated_participants, updated_participant_notifications} <-
               update_opponent_participants(participants) do
          # Collect and send notifications manually
          notifications =
            List.flatten([
              match_notification,
              summoner_notifications,
              created_participant_notifications,
              updated_participant_notifications
            ])

          Ash.Notifier.notify(notifications)

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
    Enum.reduce_while(summoners_to_create, {:ok, [], []}, fn %{
                                                               summoner_data: summoner_data,
                                                               account_data: account_data
                                                             },
                                                             {:ok, summoners, notifications} ->
      case Lor.Lol.Summoner.create_from_api(
             platform_id,
             summoner_data,
             account_data,
             nil,
             return_notifications?: true
           ) do
        {:ok, summoner, notification} ->
          {:cont, {:ok, [summoner | summoners], [notification | notifications]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp create_participants(match_data, create_match, created_summoners, existing_summoners) do
    Enum.reduce_while(match_data["info"]["participants"], {:ok, [], []}, fn participant_data,
                                                                            {:ok, participants,
                                                                             notifications} ->
      case Lor.Lol.Participant.create_from_api(
             participant_data,
             existing_summoners,
             created_summoners,
             %{match_id: create_match.id},
             return_notifications?: true
           ) do
        {:ok, participant, notification} ->
          {:cont, {:ok, [participant | participants], [notification | notifications]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp update_opponent_participants(participants) do
    Enum.reduce_while(participants, {:ok, [], []}, fn participant,
                                                      {:ok, participants, notifications} ->
      case Lor.Lol.Participant.update_opponent_participant(participant, participants,
             return_notifications?: true
           ) do
        {:ok, updated_participant, notification} ->
          {:cont, {:ok, [updated_participant | participants], [notification | notifications]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end
end
