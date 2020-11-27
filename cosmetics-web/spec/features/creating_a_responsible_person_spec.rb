require "rails_helper"

RSpec.describe "Creating a responsible person", type: :feature do
  let(:user) { create(:submit_user, has_accepted_declaration: false) }

  before do
    configure_requests_for_submit_domain
    sign_in user
  end

  scenario "creating a resposible person as a individual sole trader" do
    visit(root_path)

    expect_to_be_on__responsible_person_declaration_page
    click_button "I confirm"

    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    select_options_to_create_rp_account

    select_rp_individual_account_type

    expect(page).to have_h1("UK Responsible Person details")
    fill_in_rp_sole_trader_details(name: "Auto-test rpuser")
    fill_in_rp_contact_details

    expect(page).to have_h1("Your cosmetic products")
  end

  scenario "creating a responsible person as a limited company" do
    visit(root_path)

    expect_to_be_on__responsible_person_declaration_page
    click_button "I confirm"

    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    select_options_to_create_rp_account

    select_rp_business_account_type

    expect(page).to have_h1("UK Responsible Person details")
    fill_in_rp_business_details(name: "Auto-test rpuser")
    fill_in_rp_contact_details

    expect(page).to have_h1("Your cosmetic products")
  end

  scenario "creating a responsible person with the same name as an existing one" do
    create(:responsible_person, :with_a_contact_person, name: "Auto-test rpuser")

    visit(root_path)

    expect_to_be_on__responsible_person_declaration_page
    click_button "I confirm"

    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    select_options_to_create_rp_account
    select_rp_business_account_type

    expect(page).to have_h1("UK Responsible Person details")
    fill_in_rp_business_details(name: "Auto-test rpuser")

    expect(page).not_to have_css("h2#error-summary-title", text: "There is a problem")
    fill_in_rp_contact_details

    expect(page).to have_h1("Your cosmetic products")
  end

  scenario "creating a responsible person with the same name as another responbible person the user belongs to" do
    rp = create(:responsible_person, :with_a_contact_person, name: "Auto-test rpuser")
    create(:responsible_person_user, responsible_person: rp, user: user)

    visit("/responsible_persons/#{rp.id}")

    expect_to_be_on__responsible_person_declaration_page
    click_button "I confirm"

    expect(page).to have_h1("Responsible person")
    click_link "Add new Responsible Person"
    select_rp_business_account_type

    expect(page).to have_h1("UK Responsible Person details")
    fill_in_rp_business_details(name: "Auto-test rpuser")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("You are already a member of Auto-test rpuser", href: "#responsible_person_name")
  end

  scenario "creating a responsible person with the same name as another responbible person the user is invited to" do
    rp = create(:responsible_person, :with_a_contact_person, name: "Auto-test rpuser")
    create(:pending_responsible_person_user, responsible_person: rp, email_address: user.email)

    visit(root_path)

    expect_to_be_on__responsible_person_declaration_page
    click_button "I confirm"

    expect(page).to have_h1("Who do you want to submit cosmetic product notifications for?")
    click_link "create a new Responsible Person"
    select_rp_business_account_type

    expect(page).to have_h1("UK Responsible Person details")
    fill_in_rp_business_details(name: "Auto-test rpuser")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("You have already been invited to join Auto-test rpuser. Check your email inbox for your invite", href: "#responsible_person_name")
  end
end
