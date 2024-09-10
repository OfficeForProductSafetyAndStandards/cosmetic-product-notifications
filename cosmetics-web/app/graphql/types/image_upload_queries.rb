module Types
  module ImageUploadQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific image upload by its ID
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

      # Add cursor-based pagination for image_uploads
      field :image_uploads, ImageUploadType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of image uploads.

        Example Query:
        ```
        query {
          image_uploads(first: 10, after: "<cursor>") {
            edges {
              node {
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
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
        ```
      DESC
    end

    # Method to return a specific image upload by ID
    def image_upload(id:)
      ImageUpload.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find image_upload with 'id'=#{id}"
    end

    # Method to return all image uploads with pagination support and a max limit of 100 records
    def image_uploads(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ImageUpload.limit(first || last)
    end
  end
end
