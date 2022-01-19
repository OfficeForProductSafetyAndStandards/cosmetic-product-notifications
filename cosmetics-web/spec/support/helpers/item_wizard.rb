require "support/matchers/capybara_matchers"

def complete_product_details(nanos: [])
  complete_item_wizard("Product details", single_item: true, nanos: nanos)
end

def complete_item_wizard(name, item_number: nil, single_item: false, nanos: [], from_add: false)
  label_name = single_item ? nil : name

  unless from_add
    if item_number
      click_on "Item ##{item_number}"
    else
      click_link name
    end
  end

  unless single_item
    answer_item_name_with(name)
  end

  if nanos.present?
    answer_select_which_nanomaterials_are_included_with(nanos)
    if !nanos.all?(&:nil?)
      answer_is_item_intended_to_be_rinsed_off_or_left_on_with("Rinsed off", item_name: label_name)
      answer_how_user_is_exposed_to_nanomaterials_with("Dermal")
    end
  end

  answer_is_item_available_in_shades_with "No", item_name: label_name

  answer_what_is_physical_form_of_item_with "Liquid", item_name: label_name

  answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package", item_name: label_name

  answer_does_item_contain_cmrs_with "No", item_name: label_name

  answer_item_category_with "Hair and scalp products"

  answer_item_subcategory_with "Hair and scalp care and cleansing products"

  answer_item_sub_subcategory_with "Shampoo"

  answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration", item_name: label_name

  upload_ingredients_pdf

  answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"
  expect_task_has_been_completed_page

  return_to_tasks_list_page
  expect_item_task_completed name
end

def answer_item_name_with(item_name)
  fill_in "Item name", with: item_name
  click_button "Continue"
end

def answer_select_which_nanomaterials_are_included_with(nanos)
  if nanos.all?(&:nil?)
    return click_button "Continue"
  end

  nanos.each do |nano|
    within_fieldset("Select which nanomaterials are included in the item") do
      page.check(nano)
    end
  end
  click_button "Continue"
end

def answer_is_item_available_in_shades_with(answer, item_name: nil)
  within_fieldset("Is #{item_name || 'the product'} available in different shades?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_is_item_intended_to_be_rinsed_off_or_left_on_with(answer, item_name: nil)
  within_fieldset("Is #{item_name || 'the product'} intended to be rinsed off or left on?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_how_user_is_exposed_to_nanomaterials_with(*answers)
  answers.each do |answer|
    within_fieldset("How is the user likely to be exposed to the nanomaterials?") do
      page.check(answer)
    end
  end
  click_button "Continue"
end

def answer_what_is_physical_form_of_item_with(answer, item_name: nil)
  within_fieldset("What is the physical form of #{item_name || 'the product'}?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_item_contain_cmrs_with(answer, item_name: nil)
  within_fieldset("Does #{item_name || 'the product'} contain category 1A or 1B CMR substances?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_what_is_product_contained_in_with(answer, item_name: nil)
  within_fieldset("What is #{item_name || 'the product'} contained in?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_what_type_of_applicator_with(answer)
  within_fieldset("What type of applicator?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_item_category_with(answer)
  within_fieldset("What category of cosmetic product is it?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_item_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end

def answer_item_sub_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end

def answer_how_do_you_want_to_give_formulation_with(answer, item_name: nil)
  within_fieldset("How do you want to give the formulation of #{item_name || 'the product'}?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def upload_ingredients_pdf
  if !page.has_css?('#formulation-files-table')
    page.attach_file "spec/fixtures/files/testPdf.pdf"
  end
  click_button "Continue"
end

def upload_formulation_file
  upload_formulation_file
end

def expect_product_details_task_completed
  expect_item_task_completed("Product details")
end

def expect_product_details_task_not_started
  expect_task_not_started("Product details")
end

def expect_product_details_task_blocked
  expect_task_blocked("Product details")
end

def expect_item_task_completed(name)
  expect_task_completed name
end

def expect_item_task_not_started(name)
  expect_task_not_started name
end

def select_item_and_remove(answer)
  within_fieldset("Select which item to remove") do
    page.choose(answer)
  end
  click_button "Delete and continue"
end
