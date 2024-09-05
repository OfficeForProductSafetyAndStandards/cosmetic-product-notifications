require "rails_helper"

RSpec.describe "Sign-in and select responsible person", type: :feature do
  let(:user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
  end

  scenario "Sign-in and view landing page" do
    sign_in_user_visit_landing_page
    expect(page).to have_css("h1", text: "Select the Responsible Person")
    expect(page).to have_selector("label", text: "Add a new Responsible Person")
  end

  context "when signed in and creating a responsible person" do
    before do
      sign_in_and_create_responsible_person
    end

    it "successfully creates a responsible person" do
      expect(page).to have_content("The Responsible Person was created")
    end

    context "when signed out and signed back in" do
      before do
        sign_out_and_sign_back_in
      end

      it "displays the account information" do
        within("main.govuk-main-wrapper") do
          expect(page).to have_content("Your account")
        end
      end

      it "displays the full name of the responsible person" do
        within("main.govuk-main-wrapper") do
          expect(page).to have_content("Full name #{user.name}")
        end
      end
    end
  end

  def sign_in_and_create_responsible_person
    sign_in_user_visit_landing_page
    create_responsible_person
  end

  def sign_out_and_sign_back_in
    sign_out_user_sign_back_in_view_your_account
  end

  def sign_in_user_visit_landing_page
    sign_in(user)
    visit "/my_account"
  end

  def sign_out_from_page
    click_button("Sign out")
  end

  def sign_out_user_sign_back_in_view_your_account
    sign_out_from_page
    sign_in(user)
    visit "/my_account"
    expect(page).to have_text("Test person one")
    expect(page).to have_h2("Your security preferences")
  end

  def create_responsible_person
    choose("Add a new Responsible Person")
    byebug
    click_button("Save and continue")

    # add business details
    expect(page).to have_h1("Add a Responsible Person")
    expect(page).to have_css("input[type='radio']")
    choose("Individual or sole trader")
    fill_in "Name", with: "Test person one"
    fill_in "address_line_1", with: "Test building one, street two"
    fill_in "Town or city", with: "Test town one"
    fill_in "Postcode", with: "AB12 3DE"
    byebug
    click_button("Save and continue")

    # add contact person for the rp that was created
    expect(page).to have_h1("Contact person for Test person one")
    fill_in "Full name", with: "Test contact person one"
    fill_in "Email", with: "ct_test@testing.one"
    fill_in "Telephone", with: "0123456790"
    click_button("Continue")

    # summary
    expect(page).to have_css("h2", text: "Success")
    expect(page).to have_css("h1", text: "Responsible Person")
    expect(page).to have_text("Test person one")
    expect(page).to have_text("Test contact person one")
  end
end
