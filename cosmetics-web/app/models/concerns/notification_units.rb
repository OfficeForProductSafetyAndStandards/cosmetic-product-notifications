module NotificationUnits
  extend ActiveSupport::Concern

  included do
    enum unit: {
        less_than_01_percent: "less_than_01_percent",
        greater_than_01_less_than_1_percent: "greater_than_01_less_than_1_percent",
        greater_than_1_less_than_5_percent: "greater_than_1_less_than_5_percent",
        greater_than_5_less_than_10_percent: "greater_than_5_less_than_10_percent",
        greater_than_10_less_than_25_percent: "greater_than_10_less_than_25_percent",
        greater_than_25_less_than_50_percent: "greater_than_25_less_than_50_percent",
        greater_than_50_less_than_75_percent: "greater_than_50_less_than_75_percent",
        greater_than_75_less_than_100_percent: "greater_than_75_less_than_100_percent",
    }
  end
end
