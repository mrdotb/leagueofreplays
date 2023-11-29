defmodule Lor.S3.Object do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "s3_objects"

    repo Lor.Repo
  end

  code_interface do
    define_for Lor.S3
    define :create
    define :destroy
  end

  actions do
    defaults [:create, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :bucket, :string, allow_nil?: false
    attribute :key, :string, allow_nil?: false
    attribute :file_name, :string, allow_nil?: false
    attribute :content_type, :string, allow_nil?: false
    attribute :metadata, :map

    attribute :url, :string do
      description "The public url of this ressource"
    end

    attribute :size, :integer do
      allow_nil? false
      description "Size in byte"
    end

    attribute :md5, :string do
      description "MD5 of the file encoded in base64"
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
