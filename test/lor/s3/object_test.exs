defmodule Lor.S3.ObjectTest do
  use Lor.DataCase, async: true

  setup_all context do
    body = "hello"

    params = %{
      bucket: "original",
      key: "test.txt",
      content_type: "application/octet-stream",
      file_name: "test.txt"
    }

    Map.merge(context, %{body: body, params: params})
  end

  test "upload object success without public url", %{body: body, params: params} do
    assert {:ok, object} = Lor.S3.Object.upload(body, false, params)
    assert object.bucket == params.bucket
    assert object.key == params.key
    assert object.content_type == params.content_type
    assert object.file_name == params.file_name
    assert is_nil(object.url)
  end

  test "upload object success with public url", %{body: body, params: params} do
    assert {:ok, object} = Lor.S3.Object.upload(body, true, params)
    assert is_binary(object.url)
  end

  test "upload object failure", %{body: body, params: params} do
    params = Map.put(params, :bucket, "error")

    assert_raise Ash.Error.Invalid, ~r/The upload failed\./, fn ->
      Lor.S3.Object.upload!(body, false, params)
    end
  end

  test "destroy object success", %{body: body, params: params} do
    object = Lor.S3.Object.upload!(body, false, params)
    :ok = Ash.destroy(object)
  end
end
