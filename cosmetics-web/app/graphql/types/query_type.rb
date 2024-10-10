module Types
  class QueryType < Types::BaseObject
    include CmrQueries
    include ComponentQueries
    include ContactPersonQueries
    include DeletedNotificationQueries
    include IngredientQueries
    include ImageUploadQueries
    include NotificationDeleteLogQueries
    include NotificationQueries
    include PendingResponsiblePersonUserQueries
    include ResponsiblePersonAddressLogQueries
    include ResponsiblePersonQueries
    include ResponsiblePersonUserQueries
    include SearchHistoryQueries
    include TriggerQuestionQueries
    include TriggerQuestionElementQueries
    include UserQueries
  end
end
