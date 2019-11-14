require "rails_helper"

RSpec.describe "Create a responsible person", type: :system do
  let(:user) { create(:user) }
  let(:responsible_person) { create(:responsible_person) }
  let(:business_responsible_person) { create(:business_responsible_person) }

  before do
    configure_requests_for_submit_domain
    sign_in(as_user: user)
    stub_notify_mailer
  end

  after do
    sign_out
  end

  it "succeeds with valid individual account details" do
    create_individual_responsible_person

    assert_current_path(/responsible_persons\/\d+\/notifications/)
  end

  it "succeeds with valid business account details" do
    create_business_responsible_person

    assert_current_path(/responsible_persons\/\d+\/notifications/)
  end

  it "requires an account type to be selected" do
    visit account_path(:select_type)

    assert_text "Is the UK Responsible Person a business or an individual?"
    click_on "Continue"

    assert_current_path account_path(:select_type)
    assert_text "Account type can not be blank"
  end

private

  def create_individual_responsible_person
    create_new_responsible_person
    select_individual_account_type

    assert_text "UK Responsible Person details"

    fill_in "Name", with: responsible_person.name
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_text "contact person"

    fill_in "Full name", with: responsible_person.contact_persons.first.name
    fill_in "Email address", with: responsible_person.contact_persons.first.email_address
    fill_in "Phone number", with: responsible_person.contact_persons.first.phone_number
    click_on "Continue"
  end

  def create_business_responsible_person
    create_new_responsible_person
    select_business_account_type

    assert_text "UK Responsible Person details"

    fill_in "Business name", with: business_responsible_person.name
    fill_in "Building and street", with: business_responsible_person.address_line_1
    fill_in "Town or city", with: business_responsible_person.city
    fill_in "County", with: business_responsible_person.county
    fill_in "Postcode", with: business_responsible_person.postal_code
    click_on "Continue"

    assert_text "contact person"

    fill_in "Full name", with: business_responsible_person.contact_persons.first.name
    fill_in "Email address", with: business_responsible_person.contact_persons.first.email_address
    fill_in "Phone number", with: business_responsible_person.contact_persons.first.phone_number
    click_on "Continue"
  end

  def create_new_responsible_person
    visit account_path(:overview)
    assert_text "UK Responsible Person"
    click_on "Continue"

    assert_text "Does anyone in your organisation have an account to submit cosmetic product notifications in the UK?"
    choose "option_create_new", visible: false
    click_on "Continue"
  end

  def select_business_account_type
    assert_text "Is the UK Responsible Person a business or an individual?"
    choose "responsible_person_account_type_business", visible: false
    click_on "Continue"
  end

  def select_individual_account_type
    assert_text "Is the UK Responsible Person a business or an individual?"
    choose "responsible_person_account_type_individual", visible: false
    click_on "Continue"
  end
end
