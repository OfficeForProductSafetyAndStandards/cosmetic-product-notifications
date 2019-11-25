require "rails_helper"

RSpec.describe "Notifications Dashboard", type: :feature do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
  end

  it "is able to view my Notification Dashboard" do
    expect(body).to have_css("#main-content")
  end

  it "has a errors tab" do
    expect(body).to have_css(".govuk-tabs section#incomplete")
  end

  it "has an incomplete tab" do
    expect(body).to have_css(".govuk-tabs section#errors")
  end

  it "has a complete tab" do
    expect(body).to have_css(".govuk-tabs section#notified")
  end
end
