module Types
  class QueryType < Types::BaseObject
    include Types::CmrQueries
    include ComponentNanoMaterialQueries
    include ComponentQueries
    include ContactPersonQueries
    include DeletedNotificationQueries
    include IngredientQueries
    include ImageUploadQueries
    include NanoMaterialQueries
    include NanomaterialNotificationQueries
    include NotificationQueries
    include NotificationDeleteLogQueries
    include PendingResponsiblePersonUserQueries
    include ResponsiblePersonAddressLogQueries
    include ResponsiblePersonUserQueries
    include ResponsiblePersonQueries
    include SearchHistoryQueries
    include TriggerQuestionElementQueries
    include TriggerQuestionQueries
    include UserQueries
    include VersionQueries
  end
end
