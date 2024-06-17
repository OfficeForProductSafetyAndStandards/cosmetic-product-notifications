require "rails_helper"

RSpec.describe "Sign-in and select responsible person", type: :feature do
  let(:user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
  end

  scenario "Sign-in and view landing page" do
    sign_in_user_visit_landing_page
  end

  scenario "Sign-in and create a responsible person" do

    sign_in_user_visit_landing_page
    create_responsible_person
    sign_out_user_sign_back_in_choose_rp
  end

  def sign_in_user_visit_landing_page
    sign_in(user)
    visit "/my_account"
    expect(page).to have_css("h1", text: "Select the Responsible Person")
    expect(page).to have_css("input[type='radio']")
    expect(page).to have_selector('label', text: 'Add a new Responsible Person')
  end

  def sign_out_from_page
    click_button('Sign out')
  end

  def sign_out_user_sign_back_in_choose_rp
    sign_out_from_page
    sign_in(user)
    visit "/my_account"
    expect(page).to have_text("Test person one")
    expect(page).to have_h2("Your security preferences")
  end

  def create_responsible_person
    choose('Add a new Responsible Person')
    click_button('Save and continue')

    # add business details
    expect(page).to have_h1("Add a Responsible Person")
    expect(page).to have_css("input[type='radio']")
    choose('Individual or sole trader')
    fill_in "Name", with: "Test person one"
    fill_in "address_line_1", with: "Test building one, street two"
    fill_in "Town or city", with: "Test town one"
    fill_in "Postcode", with: "AB12 3DE"
    click_button('Save and continue')

    # # add contact person for the rp that was created
    expect(page).to have_h1("Contact person for Test person one")
    fill_in "Full name", with: "Test contact person one"
    fill_in "Email", with: "ct_test@testing.one"
    fill_in "Telephone", with: "0123456790"
    click_button('Continue')

    # summary
    expect(page).to have_css("h2", text: "Success")
    expect(page).to have_css("h1", text: "Responsible Person")
    expect(page).to have_text("Test person one")
    expect(page).to have_text("Test contact person one")
  end

end
