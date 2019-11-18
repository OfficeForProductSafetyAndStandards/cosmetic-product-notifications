require "rails_helper"

RSpec.describe "Nanomaterial notifications", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "Nanomaterial tab" do

    context "when user is associated with the responsible person" do
      before do
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_tag("h1", text: "Nanomaterials")
      end
    end

    context "when user attempts to look at a another company’s nanomaterials" do

      let(:other_company) { create(:responsible_person) }

      it "raises an a 'Not authorized' error" do
        expect {
          get "/responsible_persons/#{other_company.id}/nanomaterials"
        }.to raise_error(Pundit::NotAuthorizedError)
      end

    end
  end

  describe "New nanomaterial name" do

    before do
      get "/responsible_persons/#{responsible_person.id}/nanomaterials/new"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: "Nanomaterial name")
    end

  end

end
