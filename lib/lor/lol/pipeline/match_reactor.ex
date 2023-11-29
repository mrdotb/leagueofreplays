defmodule Lor.Lol.MatchReactor do
  @moduledoc """
  Pipeline to collect and create a match.
  """
  use Reactor

  input :region
  input :platform_id
  input :match_id

  step :fetch_match, Lor.Lol.FetchMatchStep do
    argument :region, input(:region)
    argument :match_id, input(:match_id)
  end

  step :create_s3_object, Lor.Lol.CreateS3Object do
    argument :match_data, result(:fetch_match)
  end

  step :fetch_summoners, Lor.Lol.FetchSummonersStep do
    argument :platform_id, input(:platform_id)
    argument :region, input(:region)
    argument :match_data, result(:fetch_match)
  end

  step :create_match, Lor.Lol.CreateMatchStep do
    argument :platform_id, input(:platform_id)
    argument :match_data, result(:fetch_match)
    argument :s3_object, result(:create_s3_object)
    argument :summoners_data, result(:fetch_summoners)
  end
end
