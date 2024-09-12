module Types
  module IngredientQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific ingredient by its ID
      field :ingredient, IngredientType, null: false, description: <<~DESC do
        Retrieve a specific ingredient by its ID.

        Example Query:
        ```
        query {
          ingredient(id: 1) {
            id
            inci_name
            cas_number
            exact_concentration
            range_concentration
            poisonous
            used_for_multiple_shades
            minimum_concentration
            maximum_concentration
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the ingredient to retrieve"
      end

      # Add cursor-based pagination for ingredients
      field :ingredients, IngredientType.connection_type, null: false, description: <<~DESC
        Retrieve a paginated list of ingredients.

        Example Query:
        ```
        query {
          ingredients(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                inci_name
                cas_number
                exact_concentration
                range_concentration
                poisonous
                used_for_multiple_shades
                minimum_concentration
                maximum_concentration
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

      field :total_ingredients_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of ingredients available.

        Example Query:
        ```
        query {
          total_ingredients_count
        }
        ```
      DESC
    end

    # Method to return a specific ingredient by ID
    def ingredient(id:)
      Ingredient.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find ingredient with 'id'=#{id}"
    end

    # Method to return all ingredients with pagination support and a max limit of 100 records
    def ingredients(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      Ingredient.limit(first || last)
    end

    def total_ingredients_count
      Ingredient.count
    end
  end
end
