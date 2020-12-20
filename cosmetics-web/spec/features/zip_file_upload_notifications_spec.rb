require "rails_helper"

RSpec.feature "ZIP file upload notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  scenario "Using a zip file, frame formulation, single item, no nanomaterials" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on__upload_eu_notification_files_page
    upload_zip_file "testExportFile.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1000094"
    click_link "Confirm and notify"

    expect_to_be_on__check_your_answers_page(product_name: "CTPA moisture conditioner")
    expect_check_your_answers_page_to_contain(
      product_name: "CTPA moisture conditioner",
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

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "CTPA moisture conditioner"
  end

  scenario "Using a zip file, single item, no nanomaterials, with ingredients specied as ranges" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on__upload_eu_notification_files_page
    upload_zip_file "testNotificationUsingRanges.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1005901"
    click_link "Confirm and notify"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft skin whitener")
    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft skin whitener",
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

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft skin whitener"
  end

  scenario "Using a zip file, single item, no nanomaterials, with missing formulation document" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on__upload_eu_notification_files_page
    upload_zip_file "testMissingFormulationDocument.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "10000098"
    click_link "Add missing information"

    expect_to_be_on__upload_formulation_document_page("Exact concentrations of the ingredients")
    upload_formulation_file

    expect_to_be_on__check_your_answers_page(product_name: "Beautify Facial Night Cream")
    expect_check_your_answers_page_to_contain(
      product_name: "Beautify Facial Night Cream",
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

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Beautify Facial Night Cream"
  end

  scenario "Using a zip file, single item, containing nanomaterials, with missing formulation document" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on__upload_eu_notification_files_page
    upload_zip_file "testNanomaterialAndMissingFormulation.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1006034"
    click_link "Add missing information"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__upload_formulation_document_page("Exact concentrations of the ingredients")
    upload_formulation_file

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft shocking green hair dye")
    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft shocking green hair dye",
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
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft shocking green hair dye"
  end

  scenario "Verify zip file upload with multi-items with exact and range document and nano elements in each item" do
    visit new_responsible_person_add_notification_path(responsible_person)
    go_to_upload_notification_page

    upload_zip_file "Multi-Item-RangeDoc_pHRange_ExactDoc_Nano_elements.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "100608777"
    click_link "Add missing information"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__upload_formulation_document_page("Concentration ranges of the ingredients")
    upload_formulation_file

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__upload_formulation_document_page("Exact concentrations of the ingredients")
    upload_formulation_file

    expect_to_be_on__check_your_answers_page(product_name: "Multi-Item-RangeDoc_pHRange_ExactDoc_Nano")
    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "Multi-Item-RangeDoc_pHRange_ExactDoc_Nano",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "RangeDoc",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "1,3,5-Triazine, 2,4,6-tris(1,1, TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO), 31274-51-8, 31274-51-8 2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Non-oxidative hair colour products",
          formulation_given_as: "Concentration ranges",
          physical_form: "Cream or paste",
          pH_range: "4.0 to 5.0",
        },
        {
          name: "ExactValues",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Skin products",
          subcategory: "Skin cleansing products",
          sub_subcategory: "Bath / shower products",
          formulation_given_as: "Exact concentration",
          physical_form: "Loose powder",
        },
      ],
    )
    click_button "Accept and submit the cosmetic product notification"
    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Multi-Item-RangeDoc_pHRange_ExactDoc_Nano"
  end

  scenario "Verify zip file upload with multi-items with range doc and exact values and nano elements in each item" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on__upload_eu_notification_files_page
    upload_zip_file "Multi-Item-RangeDoc_pHRange_Exactvalues_Nano_modified.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1006080"
    click_link "Add missing information"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__upload_formulation_document_page("Concentration ranges of the ingredients")
    upload_formulation_file

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__check_your_answers_page(product_name: "Multi-Item-RangeDoc_pHRange_Exactvalues_Nano")
    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "Multi-Item-RangeDoc_pHRange_Exactvalues_Nano",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "RangeDoc",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "1,3,5-Triazine, 2,4,6-tris(1,1, TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO), 31274-51-8, 31274-51-8 2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Non-oxidative hair colour products",
          formulation_given_as: "Concentration ranges",
          physical_form: "Cream or paste",
          pH_range: "4.0 to 5.0",
        },
        {
          name: "ExactValues",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Skin products",
          subcategory: "Skin cleansing products",
          sub_subcategory: "Bath / shower products",
          formulation_given_as: "Exact concentration",
          physical_form: "Loose powder",
        },
      ],
    )
    click_button "Accept and submit the cosmetic product notification"
    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Multi-Item-RangeDoc_pHRange_Exactvalues_Nano"
  end

  scenario "Verify zip file upload with multi-items with exact and range values and nano elements in each item" do
    visit new_responsible_person_add_notification_path(responsible_person)
    go_to_upload_notification_page

    upload_zip_file "Multi_itemConcentrationRangeValues_ExactValues_Nano_modified.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_incomplete_notification_with_eu_reference_number "1006079"
    click_link "Add missing information"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO)"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO)"

    expect_to_be_on__check_your_answers_page(product_name: "Multi-Item-Rangevalues_Exactvalues_Nano")
    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "Multi-Item-Rangevalues_Exactvalues_Nano",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "ConcentrationRangeValues",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "1,3,5-Triazine, 2,4,6-tris(1,1, TRIS-BIPHENYL TRIAZINE / TRIS-BIPHENYL TRIAZINE (NANO), 31274-51-8, 31274-51-8 2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Non-oxidative hair colour products",
          formulation_given_as: "Concentration ranges",
          physical_form: "Cream or paste",
          pH_range: "4.0 to 5.0",
        },
        {
          name: "ExactValues",
          shades: "",
          contains_cmrs: "No",
          nanomaterials: "2,2′-Methylene-bis(6-(2H-benzotriazol-2-yl)-4- (1,1,3,3-tetramethylbutyl)phenol)/BisoctrizoleMethylene Bis- Benzotriazolyl Tetramethylbutylphenol (nano), METHYLENE BIS-BENZOTRIAZOLYL TETRAMETHYLBUTYLPHENOL (NANO), 103597-45-1, 103597-45-1",
          category: "Skin products",
          subcategory: "Skin cleansing products",
          sub_subcategory: "Bath / shower products",
          formulation_given_as: "Exact concentration",
          physical_form: "Loose powder",
        },
      ],
    )
    click_button "Accept and submit the cosmetic product notification"
    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Multi-Item-Rangevalues_Exactvalues_Nano"
  end

  feature "detecting virus in attachments", :with_stubbed_antivirus_returning_false do
    scenario "Using a zip file that contains a virus" do
      visit new_responsible_person_add_notification_path(responsible_person)

      expect_to_be_on__was_eu_notified_about_products_page
      answer_was_eu_notified_with "Yes"

      expect_to_be_on__do_you_have_the_zip_files_page
      answer_do_you_have_zip_files_with "Yes"

      expect_to_be_on__upload_eu_notification_files_page
      upload_zip_file "testExportFile.zip"

      visit responsible_person_notifications_path(responsible_person)

      expect(page).to have_link("Errors (1)", href: "#errors")
      expect_to_see_notification_error("The uploaded file has been flagged as a virus")
    end
  end
end
