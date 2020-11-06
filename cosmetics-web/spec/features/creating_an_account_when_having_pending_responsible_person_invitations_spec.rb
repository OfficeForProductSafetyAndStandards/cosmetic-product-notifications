require "rails_helper"

RSpec.describe "Creating an account when having pending responsible person invitations", :with_2fa, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person2) { create(:responsible_person, :with_a_contact_person) }
  let(:invited_user_email) { "invited_user@example.com" }
  let(:user) { User.find_by(email: invited_user_email) }

  before do
    configure_requests_for_submit_domain
  end

  scenario "user is invited by multiple responsible persons" do
    # Given user is already invited by more than one responsible persons
    create(:pending_responsible_person_user,
           email_address: invited_user_email,
           responsible_person: responsible_person)
    create(:pending_responsible_person_user,
           email_address: invited_user_email,
           responsible_person: responsible_person2)

    # When user create an account with same email
    user_creates_an_account_with_invitation_email

    # Then user should see RP invites list showing when user is invited
    expect(page).to have_css("h1", text: "Who do you want to submit cosmetic product notifications for?")
    expect(page).to have_text(responsible_person.name)
    expect(page).to have_text(responsible_person2.name)

    # And create account link
    expect(page).to have_link("create a new Responsible Person", href: "/responsible_persons/account/select_type")
  end

  def user_creates_an_account_with_invitation_email
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: invited_user_email
    click_button "Continue"

    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")

    email = delivered_emails.last
    expect(email.recipient).to eq invited_user_email
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    fill_in "Mobile number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    expect_to_be_on_secondary_authentication_page
    expect_user_to_have_received_sms_code(otp_code)
    complete_secondary_authentication_with(otp_code)

    expect_to_be_on_declaration_page
    click_button "I confirm"
  end
end
