module Types
  class QueryType < Types::BaseObject
    include CmrQueries
    include ComponentNanoMaterialQueries
    include ComponentQueries
    include ContactPersonQueries
    include DeletedNotificationQueries
    include IngredientQueries
    include ImageUploadQueries
    include NanoMaterialQueries
    include NanomaterialNotificationQueries
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
    include VersionQueries
  end
end
