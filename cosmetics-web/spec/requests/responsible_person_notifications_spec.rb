require 'rails_helper'

RSpec.describe "Responsible person notifications", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "Index page" do
    before do
      get "/responsible_persons/#{responsible_person.id}/notifications"
    end

    it "is successful" do
      expect(response.status).to eql(200)
    end

  end
end
