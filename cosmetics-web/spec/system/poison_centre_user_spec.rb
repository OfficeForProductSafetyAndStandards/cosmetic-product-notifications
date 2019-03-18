require 'rails_helper'

RSpec.describe "Poison Centre user", type: :system do
  let(:responsible_person_1) { create(:responsible_person, email_address: "one@example.com") }
  let(:responsible_person_2) { create(:responsible_person, email_address: "two@example.com") }

  let!(:rp_1_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_1) }
  let!(:rp_2_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_2) }

  let!(:draft_notification) { create(:draft_notification, responsible_person: responsible_person_1) }
  let!(:imported_notification) { create(:imported_notification, responsible_person: responsible_person_1) }

  before do
    rp_1_notifications
    rp_2_notifications
    draft_notification
    imported_notification

    sign_in_as_poison_centre_user
    Notification.elasticsearch.import force: true
    visit root_path
  end

  after do
    sign_out
  end

  it "is redirected to the notifications index page" do
    assert_current_path(/notifications/)
  end

  it "can view a list of all registered notifications" do
    (rp_1_notifications + rp_2_notifications).each do |notification|
      assert_text notification.product_name
    end
  end

  it "cannot see any drafts in the list of notifications" do
    assert_no_text draft_notification.product_name
  end

  it "is able to see the product details for a registered notification" do
    notification = rp_1_notifications.first
    click_on notification.product_name

    assert_value for_attribute: "Name", to_be: notification.product_name
    assert_value for_attribute: "Reference number", to_be: notification.reference_number
    assert_value for_attribute: "Number of components", to_be: notification.components.count
    assert_value for_attribute: "Imported", to_be: "No"
    assert_value for_attribute: "Shades", to_be: "None"
  end

  it "is able to see the Responsible Person details for a registered notification" do
    notification = rp_1_notifications.first
    click_on notification.product_name

    assert_value for_attribute: "Name", to_be: notification.responsible_person.name
    assert_value for_attribute: "Email address", to_be: notification.responsible_person.email_address
    assert_value for_attribute: "Phone number", to_be: notification.responsible_person.phone_number
    assert_value for_attribute: "Address", to_be: notification.responsible_person.address_lines.join
  end

private

  def assert_value(for_attribute:, to_be:)
    row = first('tr', text: for_attribute)
    expect(row).to have_text(to_be)
  end
end
