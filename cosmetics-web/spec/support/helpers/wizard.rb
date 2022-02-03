require "support/matchers/capybara_matchers"

def expect_task_has_been_completed_page
  expect(page).to have_css("h3", text: "The task has been completed")
end

def return_to_tasks_list_page
  click_on "tasks list page"
end

def expect_accept_and_submit_not_started
  expect_task_not_started("Accept and submit")
end

def expect_accept_and_submit_blocked
  expect_task_blocked("Accept and submit")
end

def expect_task_completed(link_text)
  expect_task_status(link_text, "Completed")
end

def expect_task_not_started(link_text)
  expect_task_status(link_text, "Not started")
end

def expect_task_blocked(link_text)
  status = "Cannot start yet"
  expect do
    page.find(:xpath, "//span[contains(text(),'#{link_text}')]").find(:xpath, "following-sibling::b[contains(text(), '#{status}')]")
  end.not_to raise_error, "Cannot find '#{link_text}' with status '#{status}'"
end

def expect_task_status(link_text, status)
  expect do
    page.find(:xpath, "//ancestor::span/a[contains(text(),'#{link_text}')]").find(:xpath, "../following-sibling::b[contains(text(), '#{status}')]")
  end.not_to raise_error, "Cannot find '#{link_text}' with status '#{status}'"
end

# rubocop:disable Naming/MethodParameterName
def expect_check_your_answers_page_to_contain(product_name:, number_of_components:, shades:, contains_cmrs: nil, nanomaterials:, category:, subcategory:, sub_subcategory:, formulation_given_as:, frame_formulation: nil, physical_form:, ph: nil, application_instruction: nil, exposure_condition: nil, eu_notification_date: nil, poisonous_ingredients: nil)
  within("#product-table") do
    expect(page).to have_summary_item(key: "Product name", value: product_name)
    expect(page).to have_summary_item(key: "Shades", value: shades)
    expect(page).to have_summary_item(key: "Number of items", value: number_of_components)
  end

  expect(page).to have_summary_item(key: "Nanomaterials", value: nanomaterials)
  expect(page).to have_summary_item(key: "Category of product", value: category)
  expect(page).to have_summary_item(key: "Category of #{category.downcase.singularize}", value: subcategory)
  expect(page).to have_summary_item(key: "Category of #{subcategory.downcase.singularize}", value: sub_subcategory)
  expect(page).to have_summary_item(key: "Formulation given as", value: formulation_given_as)

  if contains_cmrs
    expect(page).to have_summary_item(key: "Contains CMR substances", value: contains_cmrs)
  end

  if eu_notification_date
    expect(page).to have_summary_item(key: "EU notification date", value: eu_notification_date)
  end

  if frame_formulation
    expect(page).to have_summary_item(key: "Frame formulation", value: frame_formulation)
  end

  expect(page).to have_summary_item(key: "Physical form", value: physical_form)

  if poisonous_ingredients
    expect(page).to have_summary_item(key: "Contains ingredients NPIS needs to know about", value: poisonous_ingredients)
  end

  if ph
    expect(page).to have_summary_item(key: "pH", value: ph)
  end

  if application_instruction
    expect(page).to have_summary_item(key: "Application instruction", value: application_instruction)
  end

  if exposure_condition
    expect(page).to have_summary_item(key: "Exposure condition", value: exposure_condition)
  end
end
# rubocop:enable Naming/MethodParameterName

def expect_check_your_answers_page_for_kit_items_to_contain(product_name:, number_of_components:, components_mixed:, kit_items:)
  within("#product-table") do
    expect(page).to have_summary_item(key: "Product name", value: product_name)
    expect(page).to have_summary_item(key: "Number of items", value: number_of_components)
    expect(page).to have_summary_item(key: "Are the items mixed?", value: components_mixed)
  end

  kit_items.each do |kit_item|
    expect(page).to have_selector("h3", text: kit_item[:name])

    within("##{kit_item[:name].parameterize}") do
      expect(page).to have_summary_item(key: "Shades", value: kit_item[:shades])

      if kit_item[:contains_cmrs]
        expect(page).to have_summary_item(key: "Contains CMR substances", value: kit_item[:contains_cmrs])
      end

      expect(page).to have_summary_item(key: "Nanomaterials", value: kit_item[:nanomaterials])

      if kit_item[:application_instruction]
        expect(page).to have_summary_item(key: "Application instruction", value: kit_item[:application_instruction])
      end

      if kit_item[:exposure_condition]
        expect(page).to have_summary_item(key: "Exposure condition", value: kit_item[:exposure_condition])
      end

      expect(page).to have_summary_item(key: "Category of product", value: kit_item[:category])
      expect(page).to have_summary_item(key: "Category of #{kit_item[:category].downcase.singularize}", value: kit_item[:subcategory])
      expect(page).to have_summary_item(key: "Category of #{kit_item[:subcategory].downcase.singularize}", value: kit_item[:sub_subcategory])
      expect(page).to have_summary_item(key: "Formulation given as", value: kit_item[:formulation_given_as])
      expect(page).to have_summary_item(key: "Physical form", value: kit_item[:physical_form])
      # expect(page).to have_summary_item(key: "pH", value: kit_item[:ph])
    end
  end
end

def expect_successful_submission
  expect(page).to have_current_path(/\/responsible_persons\/#{responsible_person.id}\/notifications\/\d+\/confirm/)
  expect(page).to have_h1("Submission complete")
end
