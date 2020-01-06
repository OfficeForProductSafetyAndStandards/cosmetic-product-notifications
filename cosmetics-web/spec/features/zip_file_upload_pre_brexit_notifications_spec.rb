require "rails_helper"

RSpec.describe "ZIP file upload, pre-Brexit notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end


  # ---- ZIP file, pre-Brexit ------

  scenario "Using a zip file, pre-Brexit, frame formulation, single item, no nanomaterials", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on_was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on_do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on_upload_eu_notification_files_page
    upload_zip_file "testExportFile.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1000094"
    click_link "Confirm and notify"

    expect_to_be_on_check_your_answers_page(product_name: "CTPA moisture conditioner")
    expect_check_your_answers_page_to_contain(
      product_name: "CTPA moisture conditioner",
      imported: "Manufactured in EU before Brexit",
      number_of_components: "1",
      shades: "",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Hair conditioner",
      formulation_given_as: "Frame formulation",
      physical_form: "Liquid",
      ph: "",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on_your_cosmetic_products_page
    expect_to_see_message "CTPA moisture conditioner notification submitted"
  end
end
