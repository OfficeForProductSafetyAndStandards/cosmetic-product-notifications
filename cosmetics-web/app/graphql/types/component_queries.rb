module Types
  module ComponentQueries
    extend ActiveSupport::Concern

    included do
      field :component, ComponentType, null: false, description: <<~DESC do
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

      field :components, [ComponentType], null: false, description: <<~DESC
        Retrieve a list of components.

        Example Query:
        ```
        query {
          components {
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
    end

    def component(id:)
      Component.find(id)
    end

    def components
      Component.all
    end
  end
end
