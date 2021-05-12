require "csv"

class NotificationsDecorator
  HEADER = [
    "Product name",
    "UK cosmetic product number",
    "Notification date",
    "EU Reference number",
    "EU Notification date",
    "Internal reference",
    "Number of items",
  ].freeze

  ATTRIBUTES = %i[product_name
                  reference_number_for_display
                  updated_at
                  cpnp_reference
                  cpnp_notification_date
                  industry_reference
                  components_count].freeze

  def initialize(notifications)
    @notifications = notifications
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADER + categories_headers
      @notifications.each do |notification|
        csv << NotificationDecorator.new(notification).as_csv
      end
    end
  end

private

  def categories_headers
    categories = []
    components_count = @notifications.map { |x| x.components.count }.max

    components_count.times do |i|
      categories << ["Item #{i + 1} Level 1 category",
                     "Item #{i + 1} Level 2 category",
                     "Item #{i + 1} Level 3 category"]
    end

    categories.flatten
  end
end
