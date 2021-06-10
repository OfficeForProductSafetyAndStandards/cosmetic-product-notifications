class NotificationDecorator
  def initialize(notification)
    @notification = notification
  end

  def as_csv
    NotificationsDecorator::ATTRIBUTES.map { |attr|
      @notification.public_send(attr)
    } + categories_to_csv
  end

private

  def categories_to_csv
    @notification.csv_cache&.flatten || []
  end
end
