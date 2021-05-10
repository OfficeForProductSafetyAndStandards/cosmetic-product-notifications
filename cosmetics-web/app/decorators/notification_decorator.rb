class NotificationDecorator
  def initialize(notification)
    @notification = notification
  end

  def as_csv
    NotificationsDecorator::ATTRIBUTES.map do |attr|
      @notification.public_send(attr)
    end + categories_to_csv
  end

  private
  def categories_to_csv
    @notification.components.map do |component|
      [component.root_category, component.sub_category, component.sub_sub_category].map(&:to_s).map(&:humanize)
    end.flatten
  end
end
