class NotificationSearchResultDecorator
  attr_reader :notification

  delegate_missing_to :@notification

  def initialize(notification)
    @notification = notification
  end

  def has_shades?
    shades.present? || components_have_shades?
  end

  def are_these_items_mixed
    return "No" unless notification.is_multicomponent?

    notification.components_are_mixed ? "Yes" : "No"
  end

private

  def components_have_shades?
    components.pluck(:shades).flatten.compact.uniq.any?
  end
end
