return if ResponsiblePerson.count.positive?

SEARCH_USER_ROLES = %w[poison_centre opss_science opss_general opss_enforcement trading_standards opss_imt].freeze

def get_users(env_users)
  env_users.to_s.split(";")
end

ActiveRecord::Base.transaction do
  ApiKey.create_with_generated_key(team: "Test Team")

  responsible_persons_data = [
    {
      account_type: "individual",
      name: "Some Trader",
      address_line_1: "Government Court",
      address_line_2: "18 High Road",
      city: "LONDON",
      county: "Hertfordshire",
      postal_code: "SO14 5QF",
    },
    {
      account_type: "individual",
      name: "Some Trader Another",
      address_line_1: "Government Court",
      address_line_2: "18 High Road",
      city: "LONDON",
      county: "Hertfordshire",
      postal_code: "SO14 5QF",
    },
  ]

  responsible_persons = ResponsiblePerson.create!(responsible_persons_data)

  responsible_persons.each do |rp|
    ContactPerson.create!(
      name: "John Doe",
      email_address: "example@example.org",
      phone_number: "07700 900000",
      responsible_person: rp,
    )
  end

  submit_user = SubmitUser.first_or_create!(
    email: "submit@example.com",
    corrected_email: "submit@example.com",
    name: "Submit User",
    account_security_completed: true,
    password: "testpassword",
    secondary_authentication_methods: %w[sms],
    mobile_number: "07700 900000",
    mobile_number_verified: true,
    has_accepted_declaration: true,
    confirmed_at: Time.zone.now,
    unique_session_id: Devise.friendly_token,
    legacy_role: nil,
    legacy_type: "SubmitUser",
  )

  get_users(ENV["SEED_USERS"]).each do |user|
    name, email = user.split(":")
    email_user, email_domain = email.split("@")

    corrected_email = email_user.split("+").first + "@#{email_domain}"

    submit_user_params = {
      email: email,
      corrected_email: corrected_email,
      name: name,
      account_security_completed: true,
      password: "testpassword",
      secondary_authentication_methods: %w[sms],
      mobile_number: "07700 900000",
      mobile_number_verified: true,
      has_accepted_declaration: true,
      confirmed_at: Time.zone.now,
      unique_session_id: Devise.friendly_token,
      legacy_role: nil,
      legacy_type: "SubmitUser",
    }

    submit_user = SubmitUser.create!(submit_user_params)
    submit_user.responsible_persons << responsible_persons.first

    support_user_params = {
      email: "#{email_user}+support@#{email_domain}",
      corrected_email: corrected_email,
      name: name,
      account_security_completed: true,
      password: "testpassword",
      secondary_authentication_methods: %w[sms],
      mobile_number: "07700 900000",
      mobile_number_verified: true,
      has_accepted_declaration: true,
      confirmed_at: Time.zone.now,
      unique_session_id: Devise.friendly_token,
      legacy_role: "opss_general",
      legacy_type: "SupportUser",
    }
    support_user = SupportUser.create!(support_user_params)
    support_user.add_role(:opss_general)

    SEARCH_USER_ROLES.each do |role|
      search_user_params = {
        email: "#{email_user}+search_#{role}@#{email_domain}",
        corrected_email: corrected_email,
        name: name,
        account_security_completed: true,
        password: "testpassword",
        secondary_authentication_methods: %w[sms],
        mobile_number: "07700 900000",
        mobile_number_verified: true,
        has_accepted_declaration: true,
        confirmed_at: Time.zone.now,
        unique_session_id: Devise.friendly_token,
        legacy_role: role,
        legacy_type: "SearchUser",
      }
      role_user = SearchUser.create!(search_user_params)
      role_user.add_role(role.to_sym)
    end
  end

  keywords = %w[cream luxury premium]
  category_names = %i[skin hair nail oral]
  categories = %i[face_care_products_other_than_face_mask shampoo nail_varnish_nail_makeup toothpaste]

  responsible_persons.each_with_index do |rp, _index|
    ENV.fetch("SEED_NOTIFICATIONS_COUNT", 60).to_i.times do |i|
      notification_attributes = {
        product_name: "Scrub shower bubbles #{keywords[i % 3]} #{i} (#{category_names[i % 4]})",
        state: "notification_complete",
        responsible_person_id: rp.id,
        was_notified_before_eu_exit: false,
        under_three_years: false,
        notification_complete_at: (Time.zone.now - i.days),
        responsible_person: rp,
      }

      notification = Notification.create!(notification_attributes)

      component_attributes = {
        state: "component_complete",
        notification_id: notification.id,
        notification_type: "exact",
        sub_sub_category: categories[i % 4],
        physical_form: "other_physical_form",
        contains_poisonous_ingredients: false,
        ph: "not_applicable",
      }
      component = Component.create!(component_attributes)

      ingredients = [
        ["aqua", "dimethicone", "glycerin", "propylene glycol", "PEG", "PEG stearate", "ceteareth", "sodium silicate", "sodium carbonate"],
        ["aqua", "sodium metasilicate", "stearamidopropyl dimethylamine", "ammonium chloride", "dicetyldimonium chloride", "distearyldimonium chloride", "cetrimonium chloride", "phosphoric acid", "magnesium silicate", "citric acid"],
        ["aqua", "cyclopentasiloxane", "dimethicone", "amodimethicone", "silanes"],
      ]

      ingredients[i % 3].each do |ingredient|
        Ingredient.create(inci_name: ingredient, cas_number: "11-12-1", exact_concentration: 10, component:)
      end

      notification.cache_notification_for_csv!
    end
  end

  30.times do |i|
    NanomaterialNotification.create!(
      name: "Nanomaterial #{i + 1}",
      responsible_person_id: responsible_persons.first.id,
      user_id: SubmitUser.first.id,
      eu_notified: true,
      notified_to_eu_on: (Time.zone.now.to_date - i.days - 3.years),
      submitted_at: (Time.zone.now.to_date - i.days),
    ).file.attach(io: File.open("spec/fixtures/files/testPdf.pdf"), filename: "testPdf.pdf", content_type: "application/pdf")
  end

  ReindexOpensearchJob.new.perform
end
