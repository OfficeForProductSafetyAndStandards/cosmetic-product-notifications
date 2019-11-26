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

  it "has a complete tab" do
    visit responsible_person_notifications_path(responsible_person)

    expect(body).to have_css(".govuk-tabs section#notified")
  end

  context "when the user incomplete notifications" do
    let(:user) { responsible_person.responsible_person_users.first.user }

    before do
       create(:draft_notification, responsible_person: responsible_person)
    end

    it "should display the incomplete notification" do
      visit responsible_person_notifications_path(responsible_person)

      expect(body).to have_css(".govuk-tabs", text: "Incomplete (1)")
    end

    context "when the notification requires no more information" do
      before do
        allow_any_instance_of(Notification).to receive(:formulation_required?).and_return(false)
        allow_any_instance_of(Notification).to receive(:images_required?).and_return(false)
      end

      it "can be notified" do
        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents", text: "Confirm and notify")
      end
    end

    context "when the notification is missing information" do
      it "has requires a frame formulation" do
        allow_any_instance_of(Notification).to receive(:formulation_required?).and_return(true)
        allow_any_instance_of(Notification).to receive(:images_required?).and_return(false)

        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents", text: "Add missing information")
      end

      it "has requires a product image" do
        allow_any_instance_of(Notification).to receive(:formulation_required?).and_return(false)
        allow_any_instance_of(Notification).to receive(:images_required?).and_return(true)

        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents", text: "Add missing information")
      end

      it "has incomplete nanomaterial" do
        allow_any_instance_of(Notification).to receive(:formulation_required?).and_return(false)
        allow_any_instance_of(Notification).to receive(:images_required?).and_return(false)
        allow_any_instance_of(Notification).to receive(:nano_material_required?).and_return(true)

        visit responsible_person_notifications_path(responsible_person)

        expect(body).to have_css(".add-documents", text: "Add missing information")
      end
    end
  end
end
