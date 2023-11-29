defmodule Lor.Lol.CreateMatchFlow do
  @moduledoc """
  CreateMatchFlow

  Inside a transaction:
  - Create the match
  - Create the summoners
  - Create the participants
  - Update participants to link the opponent participant if possible

  returns the created match
  """
  use Ash.Flow

  flow do
    api Lor.Lol

    argument :platform_id, Lor.Lol.PlatformIds do
      allow_nil? false
    end

    argument :match_data, :map do
      allow_nil? false
    end

    argument :s3_object, :struct do
      # TODO update when instance_of is stable
      # constraints [instance_of: Lor.S3.Object]
      allow_nil? false
    end

    argument :summoners_data, {:array, :map} do
      allow_nil? false
    end

    argument :existing_summoners, {:array, :struct} do
      # TODO update when instance_of is stable
      # constraints [items: [instance_of: Lor.Lol.Summoner]]
      allow_nil? false
    end

    returns :create_match
  end

  steps do
    transaction :create_data do
      touches_resources [Lor.Lol.Match, Lor.Lol.Summoner, Lor.Lol.Participant]

      create :create_match, Lor.Lol.Match, :create_from_api do
        input %{
          match_data: arg(:match_data),
          s3_object_id: path(arg(:s3_object), :id)
        }
      end

      map :create_summoners, arg(:summoners_data) do
        create :create_summoner, Lor.Lol.Summoner, :create_from_api do
          input %{
            platform_id: arg(:platform_id),
            account_data: path(element(:create_summoners), :account_data),
            summoner_data: path(element(:create_summoners), :summoner_data)
          }
        end
      end

      map :create_participants, path(arg(:match_data), ["info", "participants"]) do
        create :create_participant, Lor.Lol.Participant, :create_from_api do
          input %{
            match_id: path(result(:create_match), :id),
            created_summoners: result(:create_summoners),
            existing_summoners: arg(:existing_summoners),
            participant_data: element(:create_participants)
          }
        end
      end

      map :update_opponent_participants, result(:create_participants) do
        update :update_opponent, Lor.Lol.Participant, :update_opponent_participant do
          record element(:update_opponent_participants)

          input %{
            participants: result(:create_participants)
          }
        end
      end
    end
  end
end
