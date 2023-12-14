defmodule Lor.S3.ObjectTest do
  use Lor.DataCase, async: true

  test "upload object success without public url" do
    body = "hello"

    params = %{
      bucket: "original",
      key: "test.txt",
      content_type: "application/octet-stream",
      file_name: "test.txt"
    }

    assert {:ok, object} = Lor.S3.Object.upload(body, false, params)
    assert object.bucket == params.bucket
    assert object.key == params.key
    assert object.content_type == params.content_type
    assert object.file_name == params.file_name
    assert is_nil(object.url)
  end

  test "upload object success with public url" do
    body = "hello"

    params = %{
      bucket: "original",
      key: "test.txt",
      content_type: "application/octet-stream",
      file_name: "test.txt"
    }

    assert {:ok, object} = Lor.S3.Object.upload(body, true, params)
    assert is_binary(object.url)
  end

  test "upload object failure" do
    body = "hello"

    params = %{
      bucket: "error",
      key: "test.txt",
      content_type: "application/octet-stream",
      file_name: "test.txt"
    }

    assert_raise Ash.Error.Invalid, ~r/The upload failed\./, fn ->
      Lor.S3.Object.upload!(body, false, params)
    end
  end
end
