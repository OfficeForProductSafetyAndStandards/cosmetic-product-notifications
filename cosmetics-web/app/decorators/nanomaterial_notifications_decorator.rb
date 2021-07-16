require "csv"

class NotificationsDecorator
  HEADER = [
    "Nanomaterial name",
    "UK Nanomaterial number ",
    "EU Notification date",
    "Notification date",
  ].freeze

  def initialize(nanomaterials)
    @nanomaterials = nanomaterials
  end

  def to_csv
    csv = ""
    csv << CSV.generate_line(HEADER)
    @nanomaterials.each do |nano|
      csv << nano.to_csv_row
    end
    csv
  end
end
