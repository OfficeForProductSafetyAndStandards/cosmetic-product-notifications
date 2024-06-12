module Types
  class QueryType < Types::BaseObject
    include ComponentQueries
    include IngredientQueries
    include NotificationQueries
    include DeletedNotificationQueries
  end
end
