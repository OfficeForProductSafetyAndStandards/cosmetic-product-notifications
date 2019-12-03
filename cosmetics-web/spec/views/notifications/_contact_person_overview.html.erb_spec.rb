require "rails_helper"

describe "notifications/_contact_person_overview.html.erb", type: :view do
  let(:responsible_person) { create(:responsible_person) }

  it "renders contact person overview" do
    render partial: "notifications/contact_person_overview.html.erb", locals: { contact_person: responsible_person.contact_persons.first }

    expect(rendered).to match(/Contact person/)
  end
end
