require "support/matchers/capybara_matchers"

def complete_product_details(nanos: [])
  complete_item_wizard("Product details", single_item: true, nanos: nanos)
end

def complete_item_wizard(name, item_number: nil, single_item: false, nanos: [], from_add: false, formulation_type: :exact)
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
    unless nanos.all?(&:nil?)
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

  case formulation_type
  when :exact
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration", item_name: label_name
    fill_ingredients_exact_concentrations(single_item: single_item)
  when :range
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their concentration range", item_name: label_name
    fill_ingredients_range_concentrations(single_item: single_item)
  end

  answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"
  expect_task_has_been_completed_page

  return_to_tasks_list_page
  expect_item_task_completed name
end

def answer_item_name_with(item_name)
  fill_in "component_name", with: item_name
  click_button "Save and continue"
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

def fill_ingredients_exact_concentrations(single_item: false)
  fill_ingredients_concentrations(single_item: single_item) do
    fill_in "exact_concentration", with: "0.5"
  end
end

def fill_ingredients_range_concentrations(single_item: false)
  fill_ingredients_concentrations(single_item: single_item) do
    page.choose("No")
    page.choose("Above 5% w/w up to 10% w/w")
  end
end

def fill_ingredients_concentrations(single_item: false)
  if page.has_no_css?("li", text: "FooBar ingredient")
    expect_to_be_on_add_ingredients_page
    fill_in "name", with: "FooBar ingredient"
    yield # Fill/Select ingredient concentration
    fill_in "cas_number", with: "123456-78-9"
    click_on "Save and continue"

    answer_add_another_ingredient_with("Yes", single_item: single_item)
  end

  expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["FooBar ingredient"])
  click_link "Skip"
end

def answer_what_is_ph_range_of_product_with(answer)
  within_fieldset("What is the pH range of the product?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_select_formulation_with(answer)
  page.select answer, from: "component_frame_formulation"
  click_button "Continue"
end

def answer_contain_poisonous_ingredients_with(answer)
  expect(page).to have_css("h1", text: "Does the product contain poisonous ingredients?")
  page.choose answer
  click_button "Continue"
end

def select_item_and_remove(answer)
  within_fieldset("Select which item to remove") do
    page.choose(answer)
  end
  click_button "Delete and continue"
end

def answer_add_another_ingredient_with(answer, single_item: true)
  expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
  expect(page).to have_css("p", text: "The ingredient was successfully added to the #{single_item ? 'product' : 'item'}.")
  page.choose answer
  click_button "Continue"
end

def expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: [], forced_poisonous: false)
  expect(page).to have_css("h1", text: "Add the#{forced_poisonous ? ' poisonous' : ''} ingredients")
  expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient #{ingredient_number}")

  if forced_poisonous # Poisonous checkbox is pre-selected and disabled
    expect(page).to have_checked_field("ingredient_concentration_form_poisonous", disabled: true)
  end

  if already_added.any?
    expect(page).to have_css("h2", text: "Already added")
    already_added.each do |ingredient|
      expect(page).to have_css("ol.govuk-list--number li", text: ingredient)
    end
  end
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
