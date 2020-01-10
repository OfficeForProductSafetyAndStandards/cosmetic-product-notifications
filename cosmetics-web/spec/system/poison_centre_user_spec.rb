require "rails_helper"

RSpec.describe "Poison Centre user", type: :system do
  let(:responsible_person_1) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person_2) { create(:responsible_person, :with_a_contact_person) }

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

  it "can view a list of all submitted notifications" do
    (rp_1_notifications + rp_2_notifications).each do |notification|
      assert_text notification.product_name
    end
  end

  it "cannot see any drafts in the list of notifications" do
    assert_no_text draft_notification.product_name
  end

  it "is able to see the product details for a submitted notification" do
    notification = rp_1_notifications.first
    click_on notification.product_name

    assert_text notification.product_name
  end

  it "is able to see the Responsible Person details for a submitted notification" do
    notification = rp_1_notifications.first
    click_on notification.product_name

    assert_value_in_table(get_responsible_person_table, "Name", notification.responsible_person.name)
    assert_value_in_table(get_responsible_person_table, "Address", notification.responsible_person.address_lines.join)
  end

private

  def assert_value_in_table(table, attribute_name, value)
    row = table.find("tr", text: attribute_name)
    expect(row).to have_text(value)
  end

  def get_product_table
    find("#product-table")
  end

  def get_responsible_person_table
    find("#responsible-person-table")
  end
end
