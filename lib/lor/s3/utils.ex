defmodule Lor.S3.Utils do
  @moduledoc """
  Utils function to work with files
  """

  def hash_bin_md5(body) do
    :crypto.hash(:md5, body) |> Base.encode64()
  end

  def hash_file_md5!(file_path) do
    bin = File.read!(file_path)
    hash_bin_md5(bin)
  end

  def file_size!(file_path) do
    bin = File.read!(file_path)
    byte_size(bin)
  end
end
