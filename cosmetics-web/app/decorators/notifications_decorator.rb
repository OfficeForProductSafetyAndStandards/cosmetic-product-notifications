require "csv"

class NotificationsDecorator
  HEADER = [
    "Product name",
    "Reference number",
    "Notification date",
    "EU Reference number",
    "EU Notification date",
  ].freeze

  ATTRIBUTES = %i[product_name
                  reference_number
                  updated_at
                  cpnp_reference
                  cpnp_notification_date].freeze

  def initialize(notifications)
    @notifications = notifications
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADER
      @notifications.each do |notification|
        csv << NotificationDecorator.new(notification).as_csv
      end
    end
  end
end
