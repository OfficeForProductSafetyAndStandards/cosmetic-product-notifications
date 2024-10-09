module Types
  class QueryType < Types::BaseObject
    include ComponentQueries
    include IngredientQueries
    include NotificationQueries
  end
end
