module Types
  class OrderByInputType < GraphQL::Schema::InputObject
    description "Input for sorting a query by a field and direction"

    argument :field, String, required: true, description: "The field to sort by (e.g., 'created_at', 'updated_at')"
    argument :direction, String, required: true, description: "The direction to sort in ('asc' or 'desc')"
  end
end
