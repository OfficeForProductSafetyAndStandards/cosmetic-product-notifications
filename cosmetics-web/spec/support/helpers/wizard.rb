require "support/matchers/capybara_matchers"

def expect_task_has_been_completed_page
  expect(page).to have_css("h3", text: "The task has been completed")
end

def return_to_tasks_list_page
  click_on "tasks list page"
end

def expect_task_completed(link_text)
  expect_task_status(link_text, "Completed")
end

def expect_task_status(link_text, status)
  expect do
    page.find(:xpath, "//ancestor::span/a[contains(text(),'#{link_text}')]").find(:xpath, "../following-sibling::b[contains(text(), 'Completed')]")
  end.not_to raise_error(Capybara::ElementNotFound)
end
