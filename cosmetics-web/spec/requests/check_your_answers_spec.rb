require 'rails_helper'

RSpec.describe "Check your answers page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification, responsible_person: responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  context "when visiting the page with a 'from' query string" do
    let(:from) { "/responsible_persons/1/notifications%23incomplete" }

    before do
      get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit?from=#{from}"
    end

    it "includes a back link to the incomplete notifications page" do
      expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/1/notifications#incomplete" })
    end
  end

  context "when visiting the page without a from query string" do
    before do
      get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"
    end

    it "includes a back link to the notifications page" do
      expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications" })
    end
  end
end
