defmodule Lor.S3.Object do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "s3_objects"

    repo Lor.Repo
  end

  code_interface do
    define_for Lor.S3
    define :read_all, action: :read
    define :destroy
    define :upload, args: [:body, :set_url?]
  end

  actions do
    defaults [:read]

    create :upload do
      accept [:bucket, :key, :file_name, :content_type, :metadata]

      argument :body, :binary do
        allow_nil? false
        description "The binary to upload on s3"
      end

      argument :set_url?, :boolean do
        allow_nil? false
        description "Set a public url for this object"
      end

      change Lor.S3.Object.Changes.Upload
    end

    destroy :destroy do
      primary? true

      change Lor.S3.Object.Changes.Destroy
    end
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
