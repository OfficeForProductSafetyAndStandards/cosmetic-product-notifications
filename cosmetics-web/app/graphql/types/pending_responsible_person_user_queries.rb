module Types
  module PendingResponsiblePersonUserQueries
    extend ActiveSupport::Concern

    included do
      field :pending_responsible_person_user, PendingResponsiblePersonUserType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific pending responsible person user by its ID.

        Example Query:
        ```
        query {
          pending_responsible_person_user(id: 1) {
            id
            email_address
            created_at
            updated_at
            responsible_person {
              id
              name
            }
            invitation_token
            invitation_token_expires_at
            inviting_user {
              id
              email
              name
            }
            name
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the pending responsible person user to retrieve"
      end

      field :pending_responsible_person_users, PendingResponsiblePersonUserType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of pending responsible person users with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          pending_responsible_person_users(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
            edges {
              node {
                id
                email_address
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
                invitation_token
                invitation_token_expires_at
                inviting_user {
                  id
                  email
                  name
                }
                name
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve pending responsible person users created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve pending responsible person users updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      field :total_pending_responsible_person_users_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of pending responsible person users available.

        Example Query:
        ```
        query {
          total_pending_responsible_person_users_count
        }
        ```
      DESC
      end
    end

    def pending_responsible_person_user(id:)
      PendingResponsiblePersonUser.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find pending_responsible_person_user with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def pending_responsible_person_users(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = PendingResponsiblePersonUser.all

      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def total_pending_responsible_person_users_count
      PendingResponsiblePersonUser.count
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