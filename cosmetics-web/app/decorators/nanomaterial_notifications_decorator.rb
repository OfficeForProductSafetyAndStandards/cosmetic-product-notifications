require "csv"

class NanomaterialNotificationsDecorator
  HEADER = [
    "Nanomaterial name",
    "UK Nanomaterial number ",
    "EU Notification date",
    "UK Notification date",
  ].freeze

  def initialize(nanomaterials)
    @nanomaterials = nanomaterials
  end

  def to_csv
    csv = ""
    csv << CSV.generate_line(HEADER)
    @nanomaterials.each do |nano|
      csv << to_csv_row(nano)
    end
    csv
  end

  def to_csv_row(n)
    CSV.generate_line([n.name, "UKN-#{n.id}", n.notified_to_eu_on, n.submitted_at])
  end
end
