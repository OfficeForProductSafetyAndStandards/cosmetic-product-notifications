require "rails_helper"

RSpec.describe "Manual, pre-Brexit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Manual, post-Brexit, exact ingredients, single item, no nanomaterials" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "No"

    expect_to_be_on__are_you_likely_to_notify_eu_page
    answer_are_you_likely_to_notify_eu_with "No"

    expect_to_be_on__what_is_product_called_page
    answer_product_name_with "SkinSoft tangerine shampoo"

    expect_to_be_on__internal_reference_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__is_product_for_under_threes_page
    answer_is_product_for_under_threes_with "No"

    expect_to_be_on__multi_item_kits_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    exepct_to_be_on_upload_product_label_page
    upload_product_label

    expect_to_be_on__is_item_available_in_shades_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__what_is_product_contained_in_page
    answer_what_is_product_contained_in_with "A pressurised container, an impregnated sponge, wipe, patch or pad, or is encapsulated"

    expect_to_be_on__what_type_of_applicator_page
    answer_what_type_of_applicator_with "Pressurised spray"

    expect_to_be_on__does_item_contain_cmrs_page
    answer_does_item_contain_cmrs_with "No"

    expect_to_be_on__does_item_contain_nanomaterial_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products")
    answer_item_subcategory_with "Hair and scalp care and cleansing products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair and scalp care and cleansing products")
    answer_item_sub_subcategory_with "Shampoo"

    expect_to_be_on__formulation_method_page
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration"

    expect_to_be_on__upload_ingredients_page
    upload_ingredients_pdf

    expect_to_be_on__what_is_ph_range_of_product_page
    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft tangerine shampoo")

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft tangerine shampoo",
      number_of_components: "1",
      shades: "None",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Shampoo",
      formulation_given_as: "Exact concentration",
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft tangerine shampoo notification submitted"
  end

  scenario "Manual, post-Brexit, ingredient ranges, single item, no nanomaterials" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "No"

    expect_to_be_on__are_you_likely_to_notify_eu_page
    answer_are_you_likely_to_notify_eu_with "No"

    expect_to_be_on__what_is_product_called_page
    answer_product_name_with "SkinSoft tangerine shampoo"

    expect_to_be_on__internal_reference_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__is_product_for_under_threes_page
    answer_is_product_for_under_threes_with "No"

    expect_to_be_on__multi_item_kits_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    exepct_to_be_on_upload_product_label_page
    upload_product_label

    expect_to_be_on__is_item_available_in_shades_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__what_is_product_contained_in_page
    answer_what_is_product_contained_in_with "A pressurised container, an impregnated sponge, wipe, patch or pad, or is encapsulated"

    expect_to_be_on__what_type_of_applicator_page
    answer_what_type_of_applicator_with "Pressurised spray"

    expect_to_be_on__does_item_contain_cmrs_page
    answer_does_item_contain_cmrs_with "No"

    expect_to_be_on__does_item_contain_nanomaterial_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products")
    answer_item_subcategory_with "Hair and scalp care and cleansing products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair and scalp care and cleansing products")
    answer_item_sub_subcategory_with "Shampoo"

    expect_to_be_on__formulation_method_page
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their concentration range"

    expect_to_be_on__upload_ingredients_page
    upload_ingredients_pdf

    expect_to_be_on__what_is_ph_range_of_product_page
    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft tangerine shampoo")

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft tangerine shampoo",
      number_of_components: "1",
      shades: "None",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Shampoo",
      formulation_given_as: "Concentration ranges",
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft tangerine shampoo notification submitted"
  end

  scenario "Manual, post-Brexit, frame formulation, single item, no nanomaterials" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "No"

    expect_to_be_on__are_you_likely_to_notify_eu_page
    answer_are_you_likely_to_notify_eu_with "No"

    expect_to_be_on__what_is_product_called_page
    answer_product_name_with "SkinSoft tangerine shampoo"

    expect_to_be_on__internal_reference_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__is_product_for_under_threes_page
    answer_is_product_for_under_threes_with "No"

    expect_to_be_on__multi_item_kits_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    exepct_to_be_on_upload_product_label_page
    upload_product_label

    expect_to_be_on__is_item_available_in_shades_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__what_is_product_contained_in_page
    answer_what_is_product_contained_in_with "A pressurised container, an impregnated sponge, wipe, patch or pad, or is encapsulated"

    expect_to_be_on__what_type_of_applicator_page
    answer_what_type_of_applicator_with "Pressurised spray"

    expect_to_be_on__does_item_contain_cmrs_page
    answer_does_item_contain_cmrs_with "No"

    expect_to_be_on__does_item_contain_nanomaterial_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products")
    answer_item_subcategory_with "Hair and scalp care and cleansing products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair and scalp care and cleansing products")
    answer_item_sub_subcategory_with "Shampoo"

    expect_to_be_on__formulation_method_page
    answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

    expect_to_be_on__frame_formulation_select_page
    give_frame_formulation_as "Soap Shampoo"

    expect_to_be_on__poisonous_ingredients_page
    answer_does_product_contain_poisonous_ingredients_with "No"

    expect_to_be_on__what_is_ph_range_of_product_page
    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft tangerine shampoo")

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft tangerine shampoo",
      number_of_components: "1",
      shades: "None",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Shampoo",
      formulation_given_as: "Frame formulation",
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft tangerine shampoo notification submitted"
  end

  scenario "Manual, post-Brexit, frame formulation (with poisonous ingredients), single item, no nanomaterials" do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on__was_eu_notified_about_products_page
    answer_was_eu_notified_with "No"

    expect_to_be_on__are_you_likely_to_notify_eu_page
    answer_are_you_likely_to_notify_eu_with "No"

    expect_to_be_on__what_is_product_called_page
    answer_product_name_with "SkinSoft tangerine shampoo"

    expect_to_be_on__internal_reference_page
    answer_do_you_want_to_give_an_internal_reference_with "No"

    expect_to_be_on__is_product_for_under_threes_page
    answer_is_product_for_under_threes_with "No"

    expect_to_be_on__multi_item_kits_page
    answer_is_product_multi_item_kit_with "No, this is a single product"

    exepct_to_be_on_upload_product_label_page
    upload_product_label

    expect_to_be_on__is_item_available_in_shades_page
    answer_is_item_available_in_shades_with "No"

    expect_to_be_on__physical_form_of_item_page
    answer_what_is_physical_form_of_item_with "Liquid"

    expect_to_be_on__what_is_product_contained_in_page
    answer_what_is_product_contained_in_with "A pressurised container, an impregnated sponge, wipe, patch or pad, or is encapsulated"

    expect_to_be_on__what_type_of_applicator_page
    answer_what_type_of_applicator_with "Pressurised spray"

    expect_to_be_on__does_item_contain_cmrs_page
    answer_does_item_contain_cmrs_with "No"

    expect_to_be_on__does_item_contain_nanomaterial_page
    answer_does_item_contain_nanomaterials_with "No"

    expect_to_be_on__item_category_page
    answer_item_category_with "Hair and scalp products"

    expect_to_be_on__item_subcategoy_page(category: "hair and scalp products")
    answer_item_subcategory_with "Hair and scalp care and cleansing products"

    expect_to_be_on__item_sub_subcategory_page(subcategory: "hair and scalp care and cleansing products")
    answer_item_sub_subcategory_with "Shampoo"

    expect_to_be_on__formulation_method_page
    answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

    expect_to_be_on__frame_formulation_select_page
    give_frame_formulation_as "Soap Shampoo"

    expect_to_be_on__poisonous_ingredients_page
    answer_does_product_contain_poisonous_ingredients_with "Yes"

    expect_to_be_on__upload_poisonous_ingredients_page
    upload_ingredients_pdf

    expect_to_be_on__what_is_ph_range_of_product_page
    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"

    expect_to_be_on__check_your_answers_page(product_name: "SkinSoft tangerine shampoo")

    expect_check_your_answers_page_to_contain(
      product_name: "SkinSoft tangerine shampoo",
      number_of_components: "1",
      shades: "None",
      contains_cmrs: "No",
      nanomaterials: "None",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Shampoo",
      formulation_given_as: "Frame formulation",
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )
    click_button "Accept and submit the cosmetic product notification"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "SkinSoft tangerine shampoo notification submitted"
  end
end
