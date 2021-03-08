require "rails_helper"

RSpec.describe "Manual, pre-Brexit notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  scenario "Manual, pre-Brexit, frame formulation, single item, no nanomaterials, no poison", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    expect_back_link_to_notifications_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    expect_back_link_to_was_eu_notified_about_products_page
    answer_do_you_have_zip_files_with "No, I’ll enter information manually"

    expect_to_be_on__was_product_notified_before_brexit_page
    expect_back_link_to_do_you_have_the_zip_files_page
    answer_was_product_notified_before_brexit_with "Yes"

    expect_to_be_on__what_is_product_called_page
    expect_back_link_to_was_product_notified_before_brexit_page
    answer_product_name_with "SkinSoft deep blue mouthwash"

    expect_to_be_on__internal_reference_page
    expect_back_link_to_what_is_product_called_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__multi_item_kits_page
    expect_back_link_to_internal_reference_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    expect_to_be_on__is_item_available_in_shades_page
    expect_back_link_to_multi_item_kits_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_item_category_with "Oral hygiene products"

    expect_to_be_on__item_subcategoy_page(category: "oral hygiene products")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Mouth wash / breath spray"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "mouth wash / breath spray")
    expect_back_link_to_item_category_page("oral_hygiene_products")
    answer_item_sub_subcategory_with "Mouth wash"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("mouth_wash")
    give_frame_formulation_as "Mouthwash"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft deep blue mouthwash")
    expect_back_link_to_what_is_ph_range_of_product_page

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft deep blue mouthwash",
      number_of_components: "1",
      shades: "None",

      nanomaterials: "None",
      category: "Oral hygiene products",
      subcategory: "Mouth wash / breath spray",
      sub_subcategory: "Mouth wash",
      formulation_given_as: "Frame formulation",
      physical_form: "Liquid",
      ph: "No pH",
      poisonous_ingredients: "No",
    )
    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft deep blue mouthwash notification submitted"
  end

  scenario "Manual, pre-Brexit, frame formulation, single item, no nanomaterials, with poison, add poison document", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    expect_back_link_to_notifications_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    expect_back_link_to_was_eu_notified_about_products_page
    answer_do_you_have_zip_files_with "No, I’ll enter information manually"

    expect_to_be_on__was_product_notified_before_brexit_page
    expect_back_link_to_do_you_have_the_zip_files_page
    answer_was_product_notified_before_brexit_with "Yes"

    expect_to_be_on__what_is_product_called_page
    expect_back_link_to_was_product_notified_before_brexit_page
    answer_product_name_with "SkinSoft deep blue mouthwash"

    expect_to_be_on__internal_reference_page
    expect_back_link_to_what_is_product_called_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__multi_item_kits_page
    expect_back_link_to_internal_reference_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    expect_to_be_on__is_item_available_in_shades_page
    expect_back_link_to_multi_item_kits_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_item_category_with "Oral hygiene products"

    expect_to_be_on__item_subcategoy_page(category: "oral hygiene products")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Mouth wash / breath spray"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "mouth wash / breath spray")
    expect_back_link_to_item_category_page("oral_hygiene_products")
    answer_item_sub_subcategory_with "Mouth wash"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("mouth_wash")
    give_frame_formulation_as "Mouthwash"

    expect_to_be_on__poisonous_ingredients_page
    answer_does_product_contain_poisonous_ingredients_with "Yes"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft deep blue mouthwash")
    expect_back_link_to_what_is_ph_range_of_product_page

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft deep blue mouthwash",
      number_of_components: "1",
      shades: "None",

      nanomaterials: "None",
      category: "Oral hygiene products",
      subcategory: "Mouth wash / breath spray",
      sub_subcategory: "Mouth wash",
      formulation_given_as: "Frame formulation",
      physical_form: "Liquid",
      ph: "No pH",
      poisonous_ingredients: "Yes",
    )

    click_link "Add ingredients document"

    expect(page.current_path).to end_with("/build/upload_formulation")
    expect(page).to have_h1("Upload a list of ingredients the National Poisons Information Service needs to know about")

    expect_back_link_to_check_your_answers_page
    upload_ingredients_pdf

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft deep blue mouthwash")
    expect(page).to have_summary_item(key: "Ingredients NPIS needs to know about", value: "testPdf.pdf")

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft deep blue mouthwash notification submitted"
  end

  scenario "Manual, pre-Brexit, frame formulation, multi-item, no nanomaterials, no poison", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    expect_back_link_to_notifications_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    expect_back_link_to_was_eu_notified_about_products_page
    answer_do_you_have_zip_files_with "No, I’ll enter information manually"

    expect_to_be_on__was_product_notified_before_brexit_page
    expect_back_link_to_do_you_have_the_zip_files_page
    answer_was_product_notified_before_brexit_with "Yes"

    expect_to_be_on__what_is_product_called_page
    expect_back_link_to_was_product_notified_before_brexit_page
    answer_product_name_with "SkinSoft strawberry blonde hair dye"

    expect_to_be_on__internal_reference_page
    expect_back_link_to_what_is_product_called_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__multi_item_kits_page
    expect_back_link_to_internal_reference_page
    answer_is_product_multi_item_kit_with "Yes"

    expect_to_be_on__how_are_items_used_together_page
    expect_back_link_to_multi_item_kits_page
    answer_does_contain_items_that_need_to_be_mixed_with "No, the items are used in sequence"

    expect_to_be_on__kit_items_page
    expect_back_link_to_how_are_items_used_together_page
    add_an_item

    expect_to_be_on__what_is_item_called_page
    expect_back_link_to_kit_items_page
    answer_item_name_with "SkinSoft strawberry blonde hair colourant"

    expect_to_be_on__is_item_available_in_shades_page(item_name: "SkinSoft strawberry blonde hair colourant")
    expect_back_link_to_what_is_item_called_page
    answer_is_item_available_in_shades_with "No", item_name: "SkinSoft strawberry blonde hair colourant"

    expect_to_be_on__physical_form_of_item_page(item_name: "SkinSoft strawberry blonde hair colourant")
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid", item_name: "SkinSoft strawberry blonde hair colourant"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "No", item_name: "SkinSoft strawberry blonde hair colourant"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products", item_name: "SkinSoft strawberry blonde hair colourant")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Hair colouring products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair colouring products", item_name: "SkinSoft strawberry blonde hair colourant")
    expect_back_link_to_item_category_page("hair_and_scalp_products")
    answer_item_sub_subcategory_with "Oxidative hair colour products"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("hair_colouring_products")
    give_frame_formulation_as "Hair Colorant (Permanent, Oxidative Type) - Type 1 : Two Components - Colorant Part"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__kit_items_page
    expect_back_link_to_what_is_ph_range_of_product_page
    add_an_item

    expect_to_be_on__what_is_item_called_page
    expect_back_link_to_kit_items_page
    answer_item_name_with "SkinSoft strawberry blonde hair fixer"

    expect_to_be_on__is_item_available_in_shades_page(item_name: "SkinSoft strawberry blonde hair fixer")
    expect_back_link_to_what_is_item_called_page
    answer_is_item_available_in_shades_with "No", item_name: "SkinSoft strawberry blonde hair fixer"

    expect_to_be_on__physical_form_of_item_page item_name: "SkinSoft strawberry blonde hair fixer"
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid", item_name: "SkinSoft strawberry blonde hair fixer"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "No", item_name: "SkinSoft strawberry blonde hair fixer"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products", item_name: "SkinSoft strawberry blonde hair fixer")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Hair colouring products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair colouring products", item_name: "SkinSoft strawberry blonde hair fixer")
    expect_back_link_to_item_category_page("hair_and_scalp_products")
    answer_item_sub_subcategory_with "Oxidative hair colour products"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("hair_colouring_products")
    give_frame_formulation_as "Hair Colorant (Permanent, Oxidative Type) - Type 1 : Two Or Three Components - Oxidative Part"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__kit_items_page
    expect_back_link_to_what_is_ph_range_of_product_page
    click_button "Continue"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft strawberry blonde hair dye")
    expect_back_link_to_kit_items_page

    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "SkinSoft strawberry blonde hair dye",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "SkinSoft strawberry blonde hair colourant",
          shades: "None",

          nanomaterials: "None",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Oxidative hair colour products",
          formulation_given_as: "Frame formulation",
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
        {
          name: "SkinSoft strawberry blonde hair fixer",
          shades: "None",

          nanomaterials: "None",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Oxidative hair colour products",
          formulation_given_as: "Frame formulation",
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
      ],
    )
    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft strawberry blonde hair dye notification submitted"
  end

  scenario "Manual, pre-Brexit, frame formulation, single item, with nanomaterials, with poison", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    expect_back_link_to_notifications_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    expect_back_link_to_was_eu_notified_about_products_page
    answer_do_you_have_zip_files_with "No, I’ll enter information manually"

    expect_to_be_on__was_product_notified_before_brexit_page
    expect_back_link_to_do_you_have_the_zip_files_page
    answer_was_product_notified_before_brexit_with "Yes"

    expect_to_be_on__what_is_product_called_page
    expect_back_link_to_was_product_notified_before_brexit_page
    answer_product_name_with "SkinSoft carbon black eyeshadow"

    expect_to_be_on__internal_reference_page
    expect_back_link_to_what_is_product_called_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__multi_item_kits_page
    expect_back_link_to_internal_reference_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    expect_to_be_on__is_item_available_in_shades_page
    expect_back_link_to_multi_item_kits_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Solid or pressed powder"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "Yes"

    expect_to_be_on__is_item_intended_to_be_rinsed_off_or_left_on_page
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_is_item_intended_to_be_rinsed_off_or_left_on_with "Left on"

    expect_to_be_on__how_is_user_exposed_to_nanomaterials_page
    expect_back_link_to_is_item_intended_to_be_rinsed_off_or_left_on_page
    answer_how_user_is_exposed_to_nanomaterials_with "Dermal"

    expect_to_be_on__list_the_nanomaterials_page
    expect_back_link_to_how_is_user_exposed_to_nanomaterials_page
    answer_nanomaterial_names_with "Carbon Black"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_list_the_nanomaterials_page
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "Carbon Black"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_what_is_the_purpose_of_nanomaterial_page
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_nanomaterial_conform_to_restrictions_page
    answer_item_category_with "Skin products"

    expect_to_be_on__item_subcategoy_page(category: "skin products")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Make-up products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "make-up products")
    expect_back_link_to_item_category_page("skin_products")
    answer_item_sub_subcategory_with "Eye shadow"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("makeup_products")
    give_frame_formulation_as "Eye Shadow, Blusher And Liner (Powder)"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "Yes"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft carbon black eyeshadow")
    expect_back_link_to_what_is_ph_range_of_product_page

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft carbon black eyeshadow",
      number_of_components: "1",
      shades: "None",

      nanomaterials: "Carbon Black",
      application_instruction: "Dermal",
      exposure_condition: "Left on",
      category: "Skin products",
      subcategory: "Make-up products",
      sub_subcategory: "Eye shadow",
      formulation_given_as: "Frame formulation",
      physical_form: "Solid or pressed powder",
      ph: "No pH",
      poisonous_ingredients: "Yes",
    )
    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft carbon black eyeshadow notification submitted"
  end

  scenario "Manual, pre-Brexit, frame formulation, multi-item, each with nanomaterials, no poison", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    expect_back_link_to_notifications_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on__do_you_have_the_zip_files_page
    expect_back_link_to_was_eu_notified_about_products_page
    answer_do_you_have_zip_files_with "No, I’ll enter information manually"

    expect_to_be_on__was_product_notified_before_brexit_page
    expect_back_link_to_do_you_have_the_zip_files_page
    answer_was_product_notified_before_brexit_with "Yes"

    expect_to_be_on__what_is_product_called_page
    expect_back_link_to_was_product_notified_before_brexit_page
    answer_product_name_with "SkinSoft nano black hair dye kit"

    expect_to_be_on__internal_reference_page
    expect_back_link_to_what_is_product_called_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__multi_item_kits_page
    expect_back_link_to_internal_reference_page
    answer_is_product_multi_item_kit_with "Yes"

    expect_to_be_on__how_are_items_used_together_page
    expect_back_link_to_multi_item_kits_page
    answer_does_contain_items_that_need_to_be_mixed_with "No, the items are used in sequence"

    expect_to_be_on__kit_items_page
    expect_back_link_to_how_are_items_used_together_page
    add_an_item

    expect_to_be_on__what_is_item_called_page
    expect_back_link_to_kit_items_page
    answer_item_name_with "SkinSoft nano black hair dye kit colourant"

    expect_to_be_on__is_item_available_in_shades_page(item_name: "SkinSoft nano black hair dye kit colourant")
    expect_back_link_to_what_is_item_called_page
    answer_is_item_available_in_shades_with "No", item_name: "SkinSoft nano black hair dye kit colourant"

    expect_to_be_on__physical_form_of_item_page(item_name: "SkinSoft nano black hair dye kit colourant")
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid", item_name: "SkinSoft nano black hair dye kit colourant"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "Yes", item_name: "SkinSoft nano black hair dye kit colourant"

    expect_to_be_on__is_item_intended_to_be_rinsed_off_or_left_on_page item_name: "SkinSoft nano black hair dye kit colourant"
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_is_item_intended_to_be_rinsed_off_or_left_on_with "Rinsed off", item_name: "SkinSoft nano black hair dye kit colourant"

    expect_to_be_on__how_is_user_exposed_to_nanomaterials_page
    expect_back_link_to_is_item_intended_to_be_rinsed_off_or_left_on_page
    answer_how_user_is_exposed_to_nanomaterials_with "Dermal"

    expect_to_be_on__list_the_nanomaterials_page item_name: "SkinSoft nano black hair dye kit colourant"
    expect_back_link_to_how_is_user_exposed_to_nanomaterials_page
    answer_nanomaterial_names_with "Carbon Black"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_list_the_nanomaterials_page
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "Carbon Black"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_what_is_the_purpose_of_nanomaterial_page
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_nanomaterial_conform_to_restrictions_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products", item_name: "SkinSoft nano black hair dye kit colourant")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Hair colouring products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair colouring products", item_name: "SkinSoft nano black hair dye kit colourant")
    expect_back_link_to_item_category_page("hair_and_scalp_products")
    answer_item_sub_subcategory_with "Oxidative hair colour products"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("hair_colouring_products")
    give_frame_formulation_as "Hair Colorant (Permanent, Oxidative Type) - Type 1 : Two Components - Colorant Part"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__kit_items_page
    expect_back_link_to_what_is_ph_range_of_product_page
    add_an_item

    expect_to_be_on__what_is_item_called_page
    expect_back_link_to_kit_items_page
    answer_item_name_with "SkinSoft nano black hair dye kit fixer"

    expect_to_be_on__is_item_available_in_shades_page(item_name: "SkinSoft nano black hair dye kit fixer")
    expect_back_link_to_what_is_item_called_page
    answer_is_item_available_in_shades_with "No", item_name: "SkinSoft nano black hair dye kit fixer"

    expect_to_be_on__physical_form_of_item_page(item_name: "SkinSoft nano black hair dye kit fixer")
    expect_back_link_to_is_item_available_in_shades_page
    answer_what_is_physical_form_of_item_with "Liquid", item_name: "SkinSoft nano black hair dye kit fixer"

    expect_to_be_on__does_item_contain_nanomaterial_page
    expect_back_link_to_physical_form_of_item_page
    answer_does_item_contain_nanomaterials_with "Yes", item_name: "SkinSoft nano black hair dye kit fixer"

    expect_to_be_on__is_item_intended_to_be_rinsed_off_or_left_on_page item_name: "SkinSoft nano black hair dye kit fixer"
    expect_back_link_to_does_item_contain_nanomaterial_page
    answer_is_item_intended_to_be_rinsed_off_or_left_on_with "Rinsed off", item_name: "SkinSoft nano black hair dye kit fixer"

    expect_to_be_on__how_is_user_exposed_to_nanomaterials_page
    expect_back_link_to_is_item_intended_to_be_rinsed_off_or_left_on_page
    answer_how_user_is_exposed_to_nanomaterials_with "Dermal"

    expect_to_be_on__list_the_nanomaterials_page item_name: "SkinSoft nano black hair dye kit fixer"
    expect_back_link_to_how_is_user_exposed_to_nanomaterials_page
    answer_nanomaterial_names_with "Carbon Black"

    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_list_the_nanomaterials_page
    answer_what_is_purpose_of_nanomaterial_with "Colourant", nanomaterial_name: "Carbon Black"

    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_what_is_the_purpose_of_nanomaterial_page
    answer_is_nanomaterial_listed_in_ec_regulation_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page nanomaterial_name: "Carbon Black"
    expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page
    answer_does_nanomaterial_conform_to_restrictions_with "Yes", nanomaterial_name: "Carbon Black"

    expect_to_be_on__item_category_page
    expect_back_link_to_does_nanomaterial_conform_to_restrictions_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products", item_name: "SkinSoft nano black hair dye kit fixer")
    expect_back_link_to_item_category_page
    answer_item_subcategory_with "Hair colouring products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair colouring products", item_name: "SkinSoft nano black hair dye kit fixer")
    expect_back_link_to_item_category_page("hair_and_scalp_products")
    answer_item_sub_subcategory_with "Oxidative hair colour products"

    expect_to_be_on__frame_formulation_select_page
    expect_back_link_to_item_category_page("hair_colouring_products")
    give_frame_formulation_as "Hair Colorant (Permanent, Oxidative Type) - Type 1 : Two Components - Colorant Part"

    expect_to_be_on__poisonous_ingredients_page
    expect_back_link_to_frame_formulation_select_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    expect_back_link_to_poisonous_ingredients_page
    answer_what_is_ph_range_of_product_with "It does not have a pH"

    expect_to_be_on__kit_items_page
    expect_back_link_to_what_is_ph_range_of_product_page
    click_button "Continue"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft nano black hair dye kit")
    expect_back_link_to_kit_items_page

    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "SkinSoft nano black hair dye kit",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "SkinSoft nano black hair dye kit colourant",
          shades: "None",

          nanomaterials: "Carbon Black",
          application_instruction: "Dermal",
          exposure_condition: "Rinsed off",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Oxidative hair colour products",
          formulation_given_as: "Frame formulation",
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
        {
          name: "SkinSoft nano black hair dye kit fixer",
          shades: "None",

          nanomaterials: "Carbon Black",
          application_instruction: "Dermal",
          exposure_condition: "Rinsed off",
          category: "Hair and scalp products",
          subcategory: "Hair colouring products",
          sub_subcategory: "Oxidative hair colour products",
          formulation_given_as: "Frame formulation",
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
      ],
    )

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft nano black hair dye kit notification submitted"
  end
end
