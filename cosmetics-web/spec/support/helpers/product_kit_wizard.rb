require "support/matchers/capybara_matchers"

def complete_multi_item_kit_wizard
  click_on "Define the multi-item kit"

  answer_does_contain_items_that_need_to_be_mixed_with("No")

  expect_task_has_been_completed_page

  return_to_task_list_page

  expect_multi_item_kit_task_completed
end

def answer_does_contain_items_that_need_to_be_mixed_with(answer)
  within_fieldset("Does the kit contain items that need to be mixed?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def expect_multi_item_kit_task_completed
  expect_task_completed "Define the multi-item kit"
end

def expect_multi_item_kit_task_not_started
  expect_task_not_started "Define the multi-item kit"
end

def expect_multi_item_kit_task_blocked
  expect_task_blocked "Define the multi-item kit"
end
