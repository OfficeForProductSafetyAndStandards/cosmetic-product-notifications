require "rails_helper"

RSpec.describe "Edit product image page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #edit" do
    before do
      get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/product_image_upload/edit"
    end

    context "when the notification has a single component" do
      let(:notification) { create(:notification, responsible_person: responsible_person, components: [create(:component)]) }

      it "has a singular page title" do
        expect(response.body).to have_tag("h1", text: "Upload an image of the product label")
      end
    end

    context "when the notification has multiple components" do
      let(:notification) { create(:notification, responsible_person: responsible_person, components: [create(:component), create(:component)]) }

      it "has a plural page title" do
        expect(response.body).to have_tag("h1", text: "Upload images of the item labels")
      end
    end

    context "when the notification has an image" do
      let(:notification) do
        create(:notification, responsible_person: responsible_person, image_uploads: [create(:image_upload)])
      end

      it "has a section for the label images" do
        expect(response.body).to have_tag("caption", text: "Label images")
      end

      it "list the images and allows to remove them" do
        expect(response.body).to include("testImage.png")
        expect(response.body).to include("Remove")
      end
    end

    context "when the notification does not have an image" do
      let(:notification) do
        create(:notification, responsible_person: responsible_person, image_uploads: [])
      end

      it "does not have a section for the label images" do
        expect(response.body).not_to have_tag("caption", text: "Label images")
      end

      it "does not show an option to remove any image" do
        expect(response.body).not_to include("Remove")
      end
    end
  end
end
