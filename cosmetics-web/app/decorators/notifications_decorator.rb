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
                  notification_complete_at
                  cpnp_reference
                  cpnp_notification_date
                  industry_reference
                  components_count].freeze

  def initialize(notifications)
    @notifications = notifications
  end

  def to_csv
    csv = ""
    csv << CSV.generate_line(HEADER + categories_headers)
    @notifications.pluck(:csv_cache).each do |row|
      csv << row
    end
    csv
  end

private

  def categories_headers
    categories = []
    components_count = Component.joins(:notification).where("notifications.responsible_person_id = ?", @notifications.first.responsible_person).group("notification_id").count.values.max

    components_count.times do |i|
      categories << ["Item #{i + 1} Level 1 category",
                     "Item #{i + 1} Level 2 category",
                     "Item #{i + 1} Level 3 category"]
    end

    categories.flatten
  end
end
