module Types
  module ComponentQueries
    extend ActiveSupport::Concern

    included do
      field :component, ComponentType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific component by its ID.

        Example Query:
        ```
        query {
          component(id: 1) {
            id
            name
            state
            shades
            notification_id
            notification_type
            frame_formulation
            sub_sub_category
            physical_form
            special_applicator
            acute_poisoning_info
            other_special_applicator
            contains_poisonous_ingredients
            minimum_ph
            maximum_ph
            ph
            exposure_condition
            exposure_routes
            routing_questions_answers
            notification_type_given_as
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to retrieve"
      end

      field :components, ComponentType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of components with optional filters for created_at, updated_at, sorting, and a starting point.
        A maximum of 100 records can be retrieved per page.

        Example Query:
        ```
        query {
          components(
            created_after: "2024-08-15T13:00:00Z",
            updated_after: "2024-08-15T13:00:00Z",
            order_by: { field: "created_at", direction: "desc" },
            first: 10,
            from_id: 1
          ) {
            edges {
              node {
                id
                name
                state
                shades
                notification_id
                notification_type
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve components created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve components updated after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :order_by, Types::OrderByInputType, required: false, camelize: false, description: "Sort results by a specified field and direction"
        argument :from_id, GraphQL::Types::ID, required: false, camelize: false, description: "Retrieve components starting from a specific ID"
      end

      field :total_components_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of components available.

        Example Query:
        ```
        query {
          total_components_count
        }
        ```
      DESC
      end
    end

    def component(id:)
      component = Component.find(id)
      component.shades ||= []
      component
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find component with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def components(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil, order_by: nil, from_id: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = Component.all

      # Filters for created_at, updated_at, and starting ID
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

      scope.map do |component|
        component.shades ||= []
        component
      end
    end

    def total_components_count
      Component.count
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

      scope
    end

    def safe_decode_cursor(cursor)
      Base64.decode64(cursor)
    rescue ArgumentError
      raise Errors::SimpleError, "Invalid cursor format"
    end
  end
end
