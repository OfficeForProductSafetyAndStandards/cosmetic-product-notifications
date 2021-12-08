require "support/matchers/capybara_matchers"

def answer_is_item_available_in_shades_with(answer, item_name: nil)
  within_fieldset("Is #{item_name || 'the product'} available in different shades?") do
    page.choose(answer)
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

def expect_product_details_task_completed
  expect_item_task_completed "Product details"
end

def expect_item_task_completed(name)
  expect_task_completed name
end
