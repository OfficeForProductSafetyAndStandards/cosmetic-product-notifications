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

      # Add cursor-based pagination for image_uploads with filtering by created_at and updated_at
      field :image_uploads, ImageUploadType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of image uploads with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          image_uploads(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve image uploads created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve image uploads updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      # Query for retrieving the total number of image uploads available
      field :total_image_uploads_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of image uploads available.

        Example Query:
        ```
        query {
          total_image_uploads_count
        }
        ```
      DESC
      end
    end

    # Method to return a specific image upload by ID
    def image_upload(id:)
      ImageUpload.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find image_upload with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    # Method to return image uploads with optional filters for created_at and updated_at, along with pagination support
    def image_uploads(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = ImageUpload.all

      # Apply filters for created_at and updated_at
      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first: first, last: last, after: after, before: before)

      scope.limit(first || last)
    end

    # Method to return the total number of image uploads available
    def total_image_uploads_count
      ImageUpload.count
    end

    private

      # Validate the pagination limit, ensuring it does not exceed max_limit
      def validate_limit(limit, max_limit)
        return nil if limit.nil?
        [limit, max_limit].min
      end

      # Pagination logic with error handling for invalid cursors
      def apply_pagination(scope, first:, last:, after: nil, before: nil)
        return scope if first.nil? && last.nil? # No pagination if both are nil

        if after.present?
          decoded_cursor = safe_decode_cursor(after)
          scope = scope.where('id > ?', decoded_cursor)
        end

        if before.present?
          decoded_cursor = safe_decode_cursor(before)
          scope = scope.where('id < ?', decoded_cursor)
        end

        scope = scope.order(id: :asc) if first
        scope = scope.order(id: :desc) if last

        scope
      end

      # Decode cursor safely, handling errors if cursor is invalid
      def safe_decode_cursor(cursor)
        Base64.decode64(cursor)
      rescue ArgumentError
        raise Errors::SimpleError, "Invalid cursor format"
      end

      # Helper method to filter by date
      def filtered_by_date(field:, date:)
        ImageUpload.where("#{field} >= ?", date)
      rescue ArgumentError
        raise Errors::SimpleError, "Invalid date format"
      end
  end
end
