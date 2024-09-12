module Types
  module ComponentQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific component by its ID
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

      # Add cursor-based pagination for components
      field :components, ComponentType.connection_type, null: false, description: <<~DESC
        Retrieve a paginated list of components.

        Example Query:
        ```
        query {
          components(first: 10, after: "<cursor>") {
            edges {
              node {
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

      field :total_components_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of components available.

        Example Query:
        ```
        query {
          total_components_count
        }
        ```
      DESC
    end

    # Method to return a specific component by ID
    def component(id:)
      Component.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find component with 'id'=#{id}"
    end

    # Method to return all components with pagination support and a max limit of 100 records
    def components(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      Component.limit(first || last)
    end

    def total_components_count
      Component.count
    end
  end
end
