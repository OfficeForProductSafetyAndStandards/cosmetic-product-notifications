module NotificationTypes
  extend ActiveSupport::Concern

  included do
    enum notification_type: {
        predefined: "predefined",
        exact: "exact",
        range: "range",
    }
  end
end
