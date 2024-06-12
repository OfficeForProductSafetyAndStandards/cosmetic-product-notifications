module Types
  module IngredientQueries
    extend ActiveSupport::Concern

    included do
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

      field :ingredients, [IngredientType], null: false, description: <<~DESC
        Retrieve a list of ingredients.

        Example Query:
        ```
        query {
          ingredients {
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
    end

    def ingredient(id:)
      Ingredient.find(id)
    end

    def ingredients
      Ingredient.all
    end
  end
end
