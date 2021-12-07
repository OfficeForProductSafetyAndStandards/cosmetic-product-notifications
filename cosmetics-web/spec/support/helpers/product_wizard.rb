require "support/matchers/capybara_matchers"

def answer_does_product_contains_nanomaterials_with(answer, amount: 1)
  within("fieldset") do
    page.choose(answer)
    if answer == Fspec::YES
      fill_in "Nanomaterials count", with: amount
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

def expect_product_task_completed
  expect_task_completed "Create the product"
end
