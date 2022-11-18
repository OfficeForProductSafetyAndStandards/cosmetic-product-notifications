require "rails_helper"

RSpec.describe "Clone notification", type: :request do
  let(:responsible_person1) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person1.responsible_person_users.first.user }
  let(:responsible_person) { responsible_person1 }
  let(:notification) { create(:notification, responsible_person:) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notification2) { create(:notification, responsible_person: other_responsible_person) }

  before do
    configure_requests_for_submit_domain

    sign_in_as_member_of_responsible_person(responsible_person1)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET /new" do
    let(:do_request) { get new_responsible_person_notification_clone_path(responsible_person, notification) }

    it "is succesful when user is associated with responsible person" do
      do_request

      expect(response).to render_template("new")
    end

    context "when user is not associated with responsible perston" do
      let(:responsible_person) { other_responsible_person }

      it "is unsuccessful" do
        expect {
          do_request
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user trying access not his notification" do
      let(:notification) { notification2 }

      it "is unsuccessful" do
        expect {
          do_request
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "POST /create" do
    let(:do_request) { post responsible_person_notification_clone_path(responsible_person, notification, notification: { product_name: "Notification clone" }) }

    it "is successful when user is associated with responsible person" do
      allow(NotificationCloner::Base).to receive(:clone)

      do_request

      expect(NotificationCloner::Base).to have_received(:clone)

      last_notification = Notification.last

      expect(response).to redirect_to(confirm_responsible_person_notification_clone_path(responsible_person, notification, cloned_notification_reference_number: last_notification.reference_number))
    end

    context "when user is not associated with responsible person" do
      let(:responsible_person) { other_responsible_person }

      it "is unsuccessful" do
        expect {
          do_request
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user trying access not his notification" do
      let(:notification) { notification2 }

      it "is unsuccessful" do
        expect {
          do_request
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
