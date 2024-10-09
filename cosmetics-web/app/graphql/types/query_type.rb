module Types
  class QueryType < Types::BaseObject
    include CmrQueries
    include ComponentQueries
    include IngredientQueries
    include NotificationQueries
    include PendingResponsiblePersonUserQueries
    include ResponsiblePersonQueries
    include ResponsiblePersonUserQueries
    include UserQueries
  end
end
