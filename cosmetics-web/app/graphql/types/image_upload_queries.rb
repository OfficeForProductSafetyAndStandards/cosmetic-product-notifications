module Types
  module ImageUploadQueries
    extend ActiveSupport::Concern

    included do
      field :image_upload, ImageUploadType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific image upload by its ID.

        Example Query:
        ```
        query {
          image_upload(id: 1) {
            id
            filename
            created_at
            updated_at
            notification_id
            notification {
              id
              product_name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the image upload to retrieve"
      end

      field :image_uploads, [ImageUploadType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all image uploads.

        Example Query:
        ```
        query {
          image_uploads {
            id
            filename
            created_at
            updated_at
            notification_id
            notification {
              id
              product_name
            }
          }
        }
        ```
      DESC
    end

    def image_upload(id:)
      ImageUpload.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find image_upload with 'id'=#{id}"
    end

    def image_uploads
      ImageUpload.all
    end
  end
end
