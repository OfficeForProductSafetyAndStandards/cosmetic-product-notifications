require "support/matchers/capybara_matchers"

def complete_product_wizard(name: "Product", items_count: 1, nano_materials_count: 0, continue_on_nano: false, continue_on_items: false)
  click_on "Create the product"

  answer_product_name_with name

  answer_do_you_want_to_give_an_internal_reference_with "No"

  answer_is_product_for_under_threes_with "No"

  if !continue_on_nano
    if nano_materials_count > 0
      answer_does_product_contains_nanomaterials_with "Yes", amount: nano_materials_count
    else
      answer_does_product_contains_nanomaterials_with "No"
    end
  else
    text = "You can add and remove nanomaterials for this notification from product draft page."
    expect(page).to have_text(text)
    click_on "Continue"
  end

  if !continue_on_items
    if items_count > 1
      answer_is_product_multi_item_kit_with "Yes", amount: items_count
    else
      answer_is_product_multi_item_kit_with "No, this is a single product"
    end
  else
    text = "You can add and remove components for this notification from product draft page."
    expect(page).to have_text(text)
    click_on "Continue"
  end

  upload_product_label

  expect_task_has_been_completed_page

  return_to_tasks_list_page

  expect_product_task_completed
end

def answer_does_product_contains_nanomaterials_with(answer, amount: 1)
  within("fieldset") do
    page.choose(answer)
    if answer == Fspec::YES
      fill_in "Nanomaterial count", with: amount
    end
  end
  click_button "Continue"
end

def answer_is_product_multi_item_kit_with(answer, amount: 1)
  within_fieldset("Is the product a multi-item kit?") do
    page.choose(answer)
    if answer == Fspec::YES
      fill_in "How many items does it contain?", with: amount
    end
  end
  click_button "Continue"
end

def expect_product_task_blocked
  expect_task_blocked "Create the product"
end

def expect_product_task_completed
  expect_task_completed "Create the product"
end