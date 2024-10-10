module Types
  module ResponsiblePersonAddressLogQueries
    extend ActiveSupport::Concern

    included do
      field :responsible_person_address_log, ResponsiblePersonAddressLogType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific responsible person address log by its ID.

        Example Query:
        ```
        query {
          responsible_person_address_log(id: 1) {
            id
            line_1
            line_2
            city
            county
            postal_code
            start_date
            end_date
            created_at
            updated_at
            responsible_person {
              id
              name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the responsible person address log to retrieve"
      end

      field :responsible_person_address_logs, ResponsiblePersonAddressLogType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of responsible person address logs with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          responsible_person_address_logs(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
            edges {
              node {
                id
                line_1
                line_2
                city
                county
                postal_code
                start_date
                end_date
                created_at
                updated_at
                responsible_person {
                  id
                  name
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve responsible person address logs created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve responsible person address logs updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      field :total_responsible_person_address_logs_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of responsible person address logs available.

        Example Query:
        ```
        query {
          total_responsible_person_address_logs_count
        }
        ```
      DESC
      end
    end

    def responsible_person_address_log(id:)
      ResponsiblePersonAddressLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find responsible_person_address_log with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def responsible_person_address_logs(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = ResponsiblePersonAddressLog.all

      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def total_responsible_person_address_logs_count
      ResponsiblePersonAddressLog.count
    end

  private

    def validate_limit(limit, max_limit)
      return nil if limit.nil?

      [limit, max_limit].min
    end

    def apply_pagination(scope, first:, last:, after: nil, before: nil)
      return scope if first.nil? && last.nil?

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
