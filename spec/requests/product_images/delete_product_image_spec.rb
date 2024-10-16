require "rails_helper"

RSpec.describe "Delete product image", type: :request do
  describe "DESTROY #destroy" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:image) { create(:image_upload) }
    let(:notification) do
      create(:draft_notification, responsible_person:, image_uploads: [image])
    end
    let(:delete_path) do
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft/delete_product_image?image_id=#{image.id}"
    end

    before do
      configure_requests_for_submit_domain
    end

    context "when signed in as a member of the responsible person" do
      before do
        sign_in_as_member_of_responsible_person(responsible_person)
      end

      after do
        sign_out(:submit_user)
      end

      it "removes the image upload from the notification" do
        expect { delete delete_path }.to change { notification.image_uploads.count }.from(1).to(0)
      end

      it "redirects the user to the product label images upload page" do
        delete delete_path
        expect(response).to redirect_to(
          "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/product/add_product_image",
        )
      end
    end

    context "when signed in as a member of a different responsible_person" do
      before do
        sign_in_as_member_of_responsible_person(create(:responsible_person, :with_a_contact_person))
      end

      after do
        sign_out(:submit_user)
      end

      it "raises an authorisation error" do
        expect { delete delete_path }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    it "not signed in users get redirected to the sign in page" do
      delete delete_path
      expect(response).to redirect_to("/sign-in")
    end
  end
end
