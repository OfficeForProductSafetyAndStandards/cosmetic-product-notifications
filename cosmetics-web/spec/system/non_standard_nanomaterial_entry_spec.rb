require "rails_helper"

RSpec.describe "Enter a nan standard nanomaterial", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    mock_antivirus_api
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
    unmock_antivirus_api
  end

  it "allows the user to submit a notification for a non-standard nanomaterial" do
    visit new_responsible_person_non_standard_nanomaterial_path(responsible_person)

    specify_name("A nanomaterial")

    # Check your answers page
    expect_check_your_answer(get_non_standard_nanomaterial_table, "Name", "A nanomaterial")
    click_button "Accept and submit the nanomaterial"

    # Confirmation page
    click_link "Back to my nanomaterials"
  end

private

  def get_non_standard_nanomaterial_table
    find("#non-standard-nanomaterial-table")
  end

  def expect_check_your_answer(table, attribute_name, value)
    row = table.find("tr", text: attribute_name)
    expect(row).to have_text(value)
  end

  def specify_name(name)
    fill_in :non_standard_nanomaterial_iupac_name, with: name
    click_button "Continue"
  end
end
