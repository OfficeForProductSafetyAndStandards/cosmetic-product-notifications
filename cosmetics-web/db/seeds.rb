# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

return if ResponsiblePerson.count.positive?

ActiveRecord::Base.transaction do
  # Create RP
  rp_attributes = {
    account_type: "individual",
    name: "Some Trader",
    address_line_1: "Goverment Court",
    address_line_2: "18 High Road",
    city: "LONDON",
    county: "Hertfordshire",
    postal_code: "SO14 5QF",
  }
  rp = ResponsiblePerson.create!(rp_attributes)
  # Create Contact Person
  contact_person_attributes = { name: "John Doe",
                                email_address: "example@example.org",
                                phone_number: "07700 900000",
                                responsible_person: rp }
  ContactPerson.create!(contact_person_attributes)
  # Create SearchUser

  search_user_attributes = {
    id: "8718d008-da2d-4975-8cbf-4502afb5f4b6",
    mobile_number: "07447809159",
    mobile_number_verified: true,
    name: "John Doe",
    has_accepted_declaration: true,
    email: "search@example.org",
    password: "password",
    failed_attempts: 0,
    second_factor_attempts_count: 0,
    secondary_authentication_operation: "secondary_authentication",
    role: "poison_centre",
    account_security_completed: true,
    secondary_authentication_methods: %w[sms],
    skip_password_validation: false,
  }
  SearchUser.create!(search_user_attributes)
  keywords = %w[cream luxury premium]
  # Create Notifications
  20.times do |i|
    notification_attributes = {
      product_name: "Scrub shower bubbles #{keywords[i % 3]} #{i}",
      state: "notification_complete",
      responsible_person_id: 1,
      was_notified_before_eu_exit: false,
      under_three_years: false,
      notification_complete_at: Time.zone.now,
      responsible_person: rp,
    }
    notification = Notification.create!(notification_attributes)

    # Create Components
    component_attributes = {
      state: "component_complete",
      notification_id: 121,
      notification_type: "predefined",
      frame_formulation: "skin_care_cream_lotion_gel",
      sub_sub_category: "face_care_products_other_than_face_mask",
      physical_form: "other_physical_form",
      contains_poisonous_ingredients: false,
      ph: "not_applicable",
      notification: notification,
    }
    Component.create!(component_attributes)
  end
end
