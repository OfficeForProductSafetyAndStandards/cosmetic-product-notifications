require "rails_helper"

RSpec.describe "Notifications Dashboard", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  it "is able to view my Notification Dashboard" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css("#main-content")
  end

  it "has a errors tab" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css(".govuk-tabs section#incomplete")
  end

  it "has an incomplete tab" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css(".govuk-tabs section#errors")
  end

  it "has a notified tab" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css(".govuk-tabs section#notified")
  end

  context "when the user has an incomplete notification" do
    let(:user) { responsible_person.responsible_person_users.first.user }

    before do
      create(:draft_notification, responsible_person: responsible_person)
    end

    it "displays the incomplete notification" do
      visit responsible_person_notifications_path(responsible_person)

      expect(body).to have_css(".govuk-tabs", text: "Incomplete (1)")
    end

    context "when the notification requires no more information" do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Notification).to receive(:missing_information?).and_return(false)
        # rubocop:enable RSpec/AnyInstance
      end

      it "can be confirmed and notified" do
        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents .confirm-and-notify")
      end
    end

    context "when the notification is missing information" do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Notification).to receive(:missing_information?).and_return(true)
        # rubocop:enable RSpec/AnyInstance
      end

      it "can be confirmed and notified" do
        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents .add-missing-info")
      end
    end
  end
end
