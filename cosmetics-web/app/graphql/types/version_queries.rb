module Types
  module VersionQueries
    extend ActiveSupport::Concern

    included do
      # Single version retrieval
      field :version, VersionType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific version by its ID.

        **Example Query:**
        ```
        query {
          version(id: "some-version-id") {
            id
            item_type
            item_id
            event
            whodunnit
            object
            object_changes
            created_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the version to retrieve"
      end

      # Paginated versions retrieval
      field :versions, VersionType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of versions with optional filters. Results can be sorted using the `order_by` argument, and you can specify a starting point with `from_id`.
        A maximum of 100 records can be retrieved per page.

        **Example Query:**
        ```
        query {
          versions(
            item_type: "User",
            item_id: "123",
            event: "update",
            whodunnit: "42",
            created_after: "2024-08-15T13:00:00Z",
            order_by: { field: "created_at", direction: "desc" },
            first: 10,
            from_id: "some-version-id"
          ) {
            edges {
              node {
                id
                item_type
                item_id
                event
                created_at
                whodunnit
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
        argument :item_type, GraphQL::Types::String, required: false, camelize: false, description: "Filter by item_type"
        argument :item_id, GraphQL::Types::ID, required: false, camelize: false, description: "Filter by item_id"
        argument :event, GraphQL::Types::String, required: false, camelize: false, description: "Filter by event (e.g., 'create', 'update', 'destroy')"
        argument :whodunnit, GraphQL::Types::String, required: false, camelize: false, description: "Filter by whodunnit"
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve versions created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :created_before, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve versions created before this date in the format 'YYYY-MM-DD HH:MM'"
        argument :order_by, Types::VersionOrderByInputType, required: false, camelize: false, description: "Sort results by a specified field and direction"
        argument :from_id, GraphQL::Types::ID, required: false, camelize: false, description: "Retrieve versions starting from a specific ID"
      end

      # Total versions count
      field :total_versions_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of versions available.

        **Example Query:**
        ```
        query {
          total_versions_count
        }
        ```
      DESC
      end
    end

    # -- Implement Resolvers Below --

    # Single version by ID
    def version(id:)
      PaperTrail::Version.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find version with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    # Paginated list of versions
    def versions(
      item_type: nil,
      item_id: nil,
      event: nil,
      whodunnit: nil,
      created_after: nil,
      created_before: nil,
      first: nil,
      last: nil,
      after: nil,
      before: nil,
      order_by: nil,
      from_id: nil
    )
      max_limit = 100
      first = validate_limit(first, max_limit)
      last  = validate_limit(last, max_limit)

      scope = PaperTrail::Version.all

      # -- Apply filters --
      scope = scope.where(item_type:)       if item_type.present?
      scope = scope.where(item_id:)         if item_id.present?
      scope = scope.where(event:)           if event.present?
      scope = scope.where(whodunnit:)       if whodunnit.present?

      if created_after.present?
        scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc)
      end

      if created_before.present?
        scope = scope.where("created_at <= ?", Time.zone.parse(created_before).utc)
      end

      # “from_id” can be used for offset-like retrieval starting after a certain Version ID
      scope = scope.where("id > ?", from_id) if from_id.present?

      # -- Apply sorting --
      if order_by.present?
        field = order_by[:field] || "created_at"
        direction = order_by[:direction]&.downcase == "desc" ? :desc : :asc
        # Secondary sort by ID for stability
        scope = scope.order(field => direction, id: direction)
      else
        # Default sort: ascending by created_at, then by id
        scope = scope.order(created_at: :asc, id: :asc)
      end

      # -- Apply pagination --
      scope = apply_pagination(scope, first:, last:, after:, before:)

      # Limit to the min of (first || last) or max_limit
      scope.limit(first || last)
    end

    # Total count of all versions
    def total_versions_count
      Version.count
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
