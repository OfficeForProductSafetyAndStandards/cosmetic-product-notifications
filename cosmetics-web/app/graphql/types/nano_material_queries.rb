module Types
  module NanoMaterialQueries
    extend ActiveSupport::Concern

    included do
      field :nano_material, NanoMaterialType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific nano material by its ID.

        Example Query:
        ```
        query {
          nano_material(id: 1) {
            id
            created_at
            updated_at
            notification_id
            inci_name
            inn_name
            iupac_name
            xan_name
            cas_number
            ec_number
            einecs_number
            elincs_number
            purposes
            confirm_toxicology_notified
            confirm_usage
            confirm_restrictions
            nanomaterial_notification_id
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the nano material to retrieve"
      end

      field :nano_materials, NanoMaterialType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of nano materials with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          nano_materials(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
            edges {
              node {
                id
                created_at
                updated_at
                notification_id
                inci_name
                inn_name
                iupac_name
                xan_name
                cas_number
                ec_number
                einecs_number
                elincs_number
                purposes
                confirm_toxicology_notified
                confirm_usage
                confirm_restrictions
                nanomaterial_notification_id
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve nano materials created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve nano materials updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      field :total_nano_materials_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of nano materials available.

        Example Query:
        ```
        query {
          total_nano_materials_count
        }
        ```
      DESC
      end
    end

    def nano_material(id:)
      NanoMaterial.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find nano_material with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def nano_materials(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = NanoMaterial.all

      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def total_nano_materials_count
      NanoMaterial.count
    end

  private

    ALLOWED_FIELDS = %w[created_at updated_at].freeze

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