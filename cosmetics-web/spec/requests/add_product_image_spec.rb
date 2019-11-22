require "rails_helper"

RSpec.describe "Add product image page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #show" do
    before do
      get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image"
    end

    context "when the notification has a single component" do
      let(:notification) { create(:notification, responsible_person: responsible_person, components: [create(:component)]) }

      it "has a singular page title" do
        get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image"
        puts "  it: #{Time.now.to_f}"
        expect(response.body).to have_tag("h1", text: "Upload an image of the product label")
      end
    end

    context "when the notification has multiple components" do
      let(:notification) { create(:notification, responsible_person: responsible_person, components: [create(:component), create(:component)]) }

      it "has a plural page title" do
        expect(response.body).to have_tag("h1", text: "Upload images of the item labels")
      end
    end
  end
end
