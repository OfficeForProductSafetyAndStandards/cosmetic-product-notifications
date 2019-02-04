require 'rails_helper'

RSpec.describe "Create a responsible person", type: :system do
  before do
    sign_in
  end

  after do
    sign_out
  end

  it "succeeds with valid individual account details" do
    responsible_person = build(:responsible_person)

    create_new_responsible_person
    select_individual_account_type

    assert_text "UK responsible person details"

    fill_in "Full name", with: responsible_person.name
    fill_in "Email address", with: responsible_person.email_address
    fill_in "Phone number", with: responsible_person.phone_number
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_current_path(/responsible_persons\/\d+/)
  end

  it "succeeds with valid business account details" do
    responsible_person = build(:business_responsible_person)

    create_new_responsible_person
    select_business_account_type

    assert_text "UK responsible person details"

    fill_in "Companies House registration number", with: responsible_person.companies_house_number
    fill_in "Registered business name", with: responsible_person.name
    fill_in "Email address", with: responsible_person.email_address
    fill_in "Phone number", with: responsible_person.phone_number
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_current_path(/responsible_persons\/\d+/)
  end

  it "requires a Companies House registration number for a business account" do
    responsible_person = build(:business_responsible_person)

    create_new_responsible_person
    select_business_account_type

    assert_text "UK responsible person details"

    fill_in "Registered business name", with: responsible_person.name
    fill_in "Email address", with: responsible_person.email_address
    fill_in "Phone number", with: responsible_person.phone_number
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_current_path account_path(:enter_details)
    assert_text "Companies House registration number can't be blank"
  end

  it "requires an account type to be selected" do
    visit account_path(:select_type)

    assert_text "Is the UK responsible person a business or individual?"
    click_on "Continue"

    assert_current_path account_path(:select_type)
    assert_text "Please select an option before continuing"
  end
end

def create_new_responsible_person
  visit account_path(:create_or_join_existing)

  assert_text "UK responsible person"
  choose "option_create_new", visible: false
  click_on "Continue"
end

def select_business_account_type
  assert_text "Is the UK responsible person a business or individual?"
  choose "responsible_person_account_type_business", visible: false
  click_on "Continue"
end

def select_individual_account_type
  assert_text "Is the UK responsible person a business or individual?"
  choose "responsible_person_account_type_individual", visible: false
  click_on "Continue"
end
