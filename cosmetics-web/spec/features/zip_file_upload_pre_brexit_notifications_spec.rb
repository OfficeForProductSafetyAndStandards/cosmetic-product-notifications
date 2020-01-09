require "rails_helper"

RSpec.describe "ZIP file upload, pre-Brexit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  scenario "Using a zip file, pre-Brexit, frame formulation, single item, no nanomaterials" do
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
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on_your_cosmetic_products_page
    expect_to_see_message "CTPA moisture conditioner notification submitted"
  end

  scenario "Using a zip file, pre-Brexit, single item, no nanomaterials, with ingredients specied as ranges" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on_was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on_do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on_upload_eu_notification_files_page
    upload_zip_file "testNotificationUsingRanges.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1005901"
    click_link "Confirm and notify"

    expect_to_be_on_check_your_answers_page(product_name: "SkinSoft skin whitener")
    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft skin whitener",
      imported: "Yes",
      imported_from: "France",
      number_of_components: "1",
      shades: "",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Skin products",
      subcategory: "Bleach for body hair products",
      sub_subcategory: "Bleach for body hair",
      formulation_given_as: "Concentration ranges",
      frame_formulation: "Bleach For Body Hair",
      physical_form: "Loose powder",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on_your_cosmetic_products_page
    expect_to_see_message "SkinSoft skin whitener notification submitted"
  end

  scenario "Using a zip file, pre-Brexit, single item, no nanomaterials, with missing formulation document" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on_was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on_do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on_upload_eu_notification_files_page
    upload_zip_file "testMissingFormulationDocument.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "10000098"
    click_link "Add missing information"

    expect_to_be_on_upload_formulation_document_page
    upload_formulation_file

    expect_to_be_on_check_your_answers_page(product_name: "Beautify Facial Night Cream")
    expect_check_your_answers_page_to_contain(
      product_name: "Beautify Facial Night Cream",
      imported: "Manufactured in EU before Brexit",
      number_of_components: "1",
      shades: "",
      eu_notification_date: "12 November 2018",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Skin products",
      subcategory: "Skin care products",
      sub_subcategory: "Face care products other than face mask",
      formulation_given_as: "Exact concentration",
      frame_formulation: "Skin Care Cream, Lotion, Gel",
      physical_form: "Cream or paste",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on_your_cosmetic_products_page
    expect_to_see_message "Beautify Facial Night Cream notification submitted"
  end

  scenario "Using a zip file, pre-Brexit, single item, containing nanomaterials, with missing formulation document" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on_was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on_do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on_upload_eu_notification_files_page
    upload_zip_file "testNanomaterialAndMissingFormulation.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1006034"
    click_link "Add missing information"

    expect_to_be_on_what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on_is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on_does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on_upload_formulation_document_page
    upload_formulation_file

    expect_to_be_on_check_your_answers_page(product_name: "SkinSoft shocking green hair dye")
    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft shocking green hair dye",
      imported: "Yes",
      imported_from: "China",
      number_of_components: "1",
      shades: "",
      eu_notification_date: "29 November 2019",
      contains_cmrs: "No",
      nanomaterials: "1,3,5-Triazine, 2,4,6-tris(1,1, TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO), 31274-51-8, 31274-51-8",
      category: "Hair and scalp products",
      subcategory: "Hair colouring products",
      sub_subcategory: "Oxidative hair colour products",
      formulation_given_as: "Exact concentration",
      frame_formulation: "Hair Colorant (Permanent, Oxidative Type) - Type 1 : Two Components - Colorant Part",
      physical_form: "Cream or paste",
    )
    # puts page.html
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on_your_cosmetic_products_page
    expect_to_see_message "SkinSoft shocking green hair dye"
  end
end
