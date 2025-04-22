# This script imports responsible person and notification data from CSV files
# It expects:
#  - db/seeds/rp_data.csv: containing responsible person data
#  - notification_names.csv: containing notification names
#
# This script is for development/test environments only
return if Rails.env.production? # Safety check to prevent running in production

require "csv"

# Helper method to safely read CSV files
def safe_read_csv(filename, options = {})
  CSV.read(filename, options)
rescue Errno::ENOENT, CSV::MalformedCSVError => e
  Rails.logger.error("Error reading '#{filename}': #{e.message}")
  []
end

# Helper method for handling phone numbers in test data
def handle_test_phone_number(_phone_from_csv)
  # IMPORTANT: This is test data only, containing fake phone numbers
  # In a real environment, phone numbers should be encrypted
  # For test/development seeds, we're using a standard UK test number
  # instead of what's in the CSV to avoid any potential real numbers
  "07700 900000" # Standard Ofcom test number
end

# Read responsible person data
data = safe_read_csv("db/seeds/rp_data.csv")
# uncomment for local testing
# data = data[0..100]

RP_COUNT = data.count

ActiveRecord::Base.transaction do
  data.each do |row|
    # Create RP
    rp_attributes = {
      account_type: row[0],
      name: row[1],
      address_line_1: row[2],
      address_line_2: row[3],
      city: row[4],
      county: row[5],
      postal_code: row[6],
    }

    rp = ResponsiblePerson.create!(rp_attributes)

    # Create Contact Person
    contact_person_attributes = {
      name: row[7],
      email_address: row[8],
      responsible_person: rp,
    }
    contact_person = ContactPerson.new(contact_person_attributes)
    contact_person.phone_number = "07700 900000"

    contact_person.save!
  end
end

rp_ids = ResponsiblePerson.order("created_at DESC").limit(RP_COUNT)

# Read notification names
names = safe_read_csv("notification_names.csv", liberal_parsing: true)
# uncomment for local testing
# names = names[0..1000]

ActiveRecord::Base.transaction do
  names.each_with_index do |row, i|
    notification_attributes = {
      product_name: row[0],
      state: "notification_complete",
      was_notified_before_eu_exit: false,
      under_three_years: false,
      notification_complete_at: (Time.zone.now - i.minutes),
      responsible_person: rp_ids[i % RP_COUNT],
    }

    Notification.create!(notification_attributes)
  end
end
