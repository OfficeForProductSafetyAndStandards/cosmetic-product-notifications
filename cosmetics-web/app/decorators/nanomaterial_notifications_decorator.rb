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

  def to_csv_row(nano)
    CSV.generate_line([nano.name, "UKN-#{nano.id}", nano.notified_to_eu_on, nano.submitted_at])
  end
end
