module Types
  module NotificationQueries
    extend ActiveSupport::Concern

    included do
      field :notification, NotificationType, null: true, camelize: false, description: <<~DESC do
        Retrieve a specific notification by its ID.

        Example Query:
        ```
        query {
          notification(id: 1) {
            id
            product_name
            state
            created_at
            updated_at
            import_country
            responsible_person_id
            reference_number
            cpnp_reference
            shades
            industry_reference
            cpnp_notification_date
            was_notified_before_eu_exit
            under_three_years
            still_on_the_market
            components_are_mixed
            ph_min_value
            ph_max_value
            notification_complete_at
            csv_cache
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the notification to retrieve"
      end

      field :notifications, NotificationType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of notifications with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.
        Results can be sorted using the `order_by` argument, and you can specify a starting point with `from_id`.

        Example Query:
        ```
        query {
          notifications(
            created_after: "2024-08-15T13:00:00Z",
            updated_after: "2024-08-15T13:00:00Z",
            order_by: { field: "created_at", direction: "desc" },
            first: 10,
            from_id: 1
          ) {
            edges {
              node {
                id
                product_name
                state
                created_at
                updated_at
                import_country
                responsible_person_id
                reference_number
                cpnp_reference
                shades
                industry_reference
                cpnp_notification_date
                was_notified_before_eu_exit
                under_three_years
                still_on_the_market
                components_are_mixed
                ph_min_value
                ph_max_value
                notification_complete_at
                csv_cache
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve notifications created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve notifications updated after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :order_by, Types::OrderByInputType, required: false, camelize: false, description: "Sort results by a specified field and direction"
        argument :from_id, GraphQL::Types::ID, required: false, camelize: false, description: "Retrieve notifications starting from a specific ID"
      end

      field :total_notification_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of notifications available.

        Example Query:
        ```
        query {
          total_notification_count
        }
        ```
      DESC
      end
    end

    def notification(id:)
      Notification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find notification with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def notifications(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil, order_by: nil, from_id: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = Notification.all

      # Apply filters
      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?
      scope = scope.where("id > ?", from_id) if from_id.present?

      # Apply sorting
      if order_by.present?
        field = order_by[:field]
        direction = order_by[:direction]&.downcase == "desc" ? :desc : :asc
        scope = scope.order(field => direction, id: direction) # Secondary sort by ID for stability
      else
        # Default sorting
        scope = scope.order(created_at: :asc, id: :asc)
      end

      # Apply pagination
      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def total_notification_count
      Notification.count
    end

  private

    def validate_limit(limit, max_limit)
      return nil if limit.nil?

      [limit, max_limit].min
    end

    def apply_pagination(scope, first:, last:, after:, before:)
      return scope if first.nil? && last.nil?

      if after.present?
        decoded_cursor = safe_decode_cursor(after)
        scope = scope.where("id > ?", decoded_cursor)
      end

      if before.present?
        decoded_cursor = safe_decode_cursor(before)
        scope = scope.where("id < ?", decoded_cursor)
      end

      scope
    end

    def safe_decode_cursor(cursor)
      Base64.decode64(cursor)
    rescue ArgumentError
      raise Errors::SimpleError, "Invalid cursor format"
    end
  end
end
