module Types
  class QueryType < Types::BaseObject
    include CmrQueries
    include ComponentQueries
    include ContactPersonQueries
    include DeletedNotificationQueries
    include IngredientQueries
    include ImageUploadQueries
    include NotificationQueries
    include PendingResponsiblePersonUserQueries
    include ResponsiblePersonQueries
    include ResponsiblePersonUserQueries
    include SearchHistoryQueries
    include UserQueries
  end
end
