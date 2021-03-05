class NotificationDecorator

  def initialize(notification)
    @notification = notification
  end

  def to_csv
    row = []
    NotificationsDecorator::ATTRIBUTES.each do |attr|
      row << @notification.send(attr)
    end
    row.join(",")
  end
end
