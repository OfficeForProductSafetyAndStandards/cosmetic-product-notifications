module Types
  module CmrQueries
    extend ActiveSupport::Concern

    included do
      field :cmr, CmrType, null: true, camelize: false, description: <<~DESC do
        Retrieve a specific CMR by its ID.

        Example Query:
        ```
        query {
          cmr(id: 1) {
            id
            name
            cas_number
            ec_number
            component_id
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the CMR to retrieve"
      end

      field :cmrs, CmrType.connection_type, null: true, camelize: false, description: <<~DESC do
        Retrieve a paginated list of CMRs with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          cmrs(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
            edges {
              node {
                id
                name
                cas_number
                ec_number
                component_id
                created_at
                updated_at
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve CMRs created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve CMRs updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      field :total_cmr_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of CMRs available.

        Example Query:
        ```
        query {
          total_cmr_count
        }
        ```
      DESC
      end
    end

    def cmr(id:)
      Cmr.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find cmr with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def cmrs(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = Cmr.all

      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def cmrs_created_after(created_after:)
      filter_cmrs_by_date(field: "created_at", date: created_after)
    end

    def cmrs_updated_after(updated_after:)
      filter_cmrs_by_date(field: "updated_at", date: updated_after)
    end

    def total_cmr_count
      Cmr.count
    end

  private

    def validate_limit(limit, max_limit)
      return nil if limit.nil?

      [limit, max_limit].min
    end

    def apply_pagination(scope, first:, last:, after:, before:)
      return scope if first.nil? && last.nil? # No pagination if both are nil

      if after.present?
        decoded_cursor = safe_decode_cursor(after)
        scope = scope.where("id > ?", decoded_cursor)
      end

      if before.present?
        decoded_cursor = safe_decode_cursor(before)
        scope = scope.where("id < ?", decoded_cursor)
      end

      scope = scope.order(id: :asc) if first
      scope = scope.order(id: :desc) if last

      scope
    end

    def safe_decode_cursor(cursor)
      Base64.decode64(cursor)
    rescue ArgumentError
      raise Errors::SimpleError, "Invalid cursor format"
    end
  end
end
