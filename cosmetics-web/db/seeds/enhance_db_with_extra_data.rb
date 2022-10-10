require "csv"
# This script expects file names.csv that contains notification names

# First, create extra RP's
# business,Wyman Lowe,Eusebio Drive,39968,East Janside,Greater London,W4 2HF,Ian Abernathy,cesar@wintheiser.biz,07700 900000
data = CSV.read("db/seeds/rp_data.csv")
data = data[0..100]
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
      phone_number: row[9],
      responsible_person: rp,
    }
    ContactPerson.create!(contact_person_attributes)
  end

  rp_ids = ResponsiblePerson.order("created_at DESC").limit(RP_COUNT)

  # lets create notifications based on names
  names = CSV.read("notification_names.csv", liberal_parsing: true)
  names = names[0..1000]

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
end
