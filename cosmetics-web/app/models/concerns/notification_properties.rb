module NotificationProperties
  extend ActiveSupport::Concern

  include NotificationTypes
  include NotificationCategories
  include NotificationUnits
  include NotificationPhysicalForms
  include NotificationSpecialApplicators
end
