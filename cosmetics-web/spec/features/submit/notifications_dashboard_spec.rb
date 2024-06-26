require "rails_helper"

RSpec.describe "Notifications Dashboard", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  it "is able to view my Notification Dashboard" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css("#main-content")
    expect(page).to have_css("#nav-label", text: responsible_person.name)
  end

  context "when the user has an incomplete notification" do
    let(:user) { responsible_person.responsible_person_users.first.user }

    before do
      create(:draft_notification, responsible_person:)
    end

    it "displays the draft notification" do
      visit responsible_person_draft_notifications_path(responsible_person)

      expect(body).to have_css("#incomplete-notifications", text: "There are currently 1 draft notifications.")
    end
  end
end
