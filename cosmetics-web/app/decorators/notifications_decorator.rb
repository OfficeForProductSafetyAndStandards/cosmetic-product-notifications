class NotificationsDecorator
  HEADER = [
    "Product name",
    "Reference number",
    "Notification date",
    "EU Reference number",
    "EU Notification date"]

  ATTRIBUTES = [:product_name,
                :reference_number,
                :updated_at,
                :cpnp_reference,
                :cpnp_notification_date]

  def initialize(notifications)
    @notifications = notifications
  end

  def to_csv
    data = [[HEADER].join(',')]
    @notifications.each do |notification|
      data << NotificationDecorator.new(notification).to_csv
    end
    data.join("\n")
  end
end
