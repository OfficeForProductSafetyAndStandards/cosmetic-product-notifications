require "support/matchers/capybara_matchers"

def answer_does_contain_items_that_need_to_be_mixed_with(answer)
  within_fieldset("Does the kit contain items that need to be mixed?") do
    page.choose(answer)
  end
  click_button "Continue"
end
