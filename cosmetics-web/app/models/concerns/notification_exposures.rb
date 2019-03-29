module NotificationExposures
  extend ActiveSupport::Concern

  included do
    enum EXPOSURE_ROUTE: {
        dermal: "dermal",
        oral: "oral",
        inhalation: "inhalation"
    }

    enum EXPOSURE_CONDITION: {
        rinse_off: "rinse_off",
        leave_on: "leave_on"
    }
  end
end
