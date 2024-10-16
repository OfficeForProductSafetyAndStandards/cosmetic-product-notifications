module NotificationTypes
  extend ActiveSupport::Concern

  included do
    enum notification_type: {
      predefined: "predefined",
      exact: "exact",
      range: "range",
    }

    enum notification_type_given_as: {
      predefined: "predefined",
      exact: "exact",
      exact_csv: "exact_csv",
      range_csv: "range_csv",
      range: "range",
    }, _prefix: :notification_type_given_as
  end
end
