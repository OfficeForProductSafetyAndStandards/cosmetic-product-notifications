module Types
  class QueryType < Types::BaseObject
    include CmrQueries
    include ComponentQueries
    include IngredientQueries
    include NotificationQueries
  end
end
