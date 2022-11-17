require "rails_helper"

RSpec.describe "Notification page", type: :request do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:component1) { create(:component, :using_exact, with_ingredients: %w[aqua tin sodium]) }

  let(:responsible_person) do
    create(:responsible_person, :with_a_contact_person,
           name: "RP1",
           address_line_1: "Foo Court",
           address_line_2: "123 High Street",
           city: "London",
           county: "City of London",
           postal_code: "SW1A 2AA")
  end
  let(:responsible_person_address_log) do
    create(:responsible_person_address_log,
           responsible_person:,
           line_1: "Bar Court",
           line_2: "1232 High Street",
           city: "Londonderry",
           county: "City of Londonderry",
           postal_code: "SW1A 2AB")
  end

  let(:cream1) { create(:notification, :registered, responsible_person:, components: [component1], notification_complete_at: 1.day.ago, product_name: "Cream 1") }

  before do
    sign_in_as_poison_centre_user

    responsible_person_address_log
    cream1
  end

  it "displays address history" do
    get poison_centre_notification_path(cream1.reference_number)

    address_lines = ["Foo Court", "123 High Street", "London", "City of London", "SW1A 2AA", "Bar Court", "1232 High Street", "Londonderry", "City of Londonderry", "SW1A 2AB"]

    expect(response.body).to match(/#{address_lines.join(".*")}/m)
  end
end
