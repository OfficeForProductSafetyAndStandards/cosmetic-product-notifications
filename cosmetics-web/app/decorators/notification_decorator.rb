class NotificationDecorator
  def initialize(notification)
    @notification = notification
  end

  def as_csv
    NotificationsDecorator::ATTRIBUTES.map do |attr|
      @notification.public_send(attr)
    end
  end
end
