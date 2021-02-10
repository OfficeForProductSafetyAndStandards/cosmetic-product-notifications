Given("I login as business user") do
  sign_in_as_business
end

Then("I should be navigated to dashboard page") do
  expect(page).to have_selector("h1", text: "Your cosmetic products")
end

Then("I should be redirected to dashboard page") do
  expect(page).to have_selector("h1", text: "Your cosmetic products")
end

When("I click add cosmetics product") do
  click_on("Add cosmetics products")
end

When("I select notified in EU {string}") do |string|
  choose(string, visible: false)
  click_button "Continue"
end

When("I select are you likely to notify in EU {string}") do |string|
  choose(string, visible: false)
  click_button "Continue"
end

When("I select {string} notified in EU") do |string|
  answer_was_eu_notified_with(string)
end

When("I select {string}") do |string|
  choose(string, visible: false)
  click_button "Continue"
  select_manual_notification_prebexit_or_post_brexit("Yes")
end

Then("I should be able to notify product manually") do
  enter_product_name("test")
  notify_post_brexit
end

Then("I should be able to notify product {string}") do |product_name|
  enter_product_name(product_name)
  notify_product("post")
end

Then("I should be able to notify {string} product {string}") do |notification, product_name|
  enter_product_name(product_name)
  notify_product(notification)
end

Then("I should be able to notify {string} product {string} in category {string} and formulation given as {string}") do |notification_type, product_name, product_category, product_formulation|
  enter_product_name(product_name)
  notify_product(notification_type, product_category, product_formulation)
  expected_h1(product_name)
end

Then("I should be able to see the entered details product name {string} and category {string} and given formation as {string}") do |product_name, product_category, product_formulation|
  validate_check_your_answer_page(product_name, product_category, product_formulation)
  page.should have_xpath("//a[contains(text(),'Save and return to dashboard')]")
end

Then("I should be able to see the entered details product name {string} and category {string} and given formulation as {string}") do |product_name, product_category, product_formulation|
  validate_check_your_answer_page(product_name, product_category, product_formulation)
end

Then("I should be able to submit product successfully") do
  click_button "Accept and submit"
  page.should have_xpath("//div[@class='hmcts-banner__message']")
end

When("I select I have zip file {string}") do |_string|
  expected_h1("EU notification ZIP files")
  select_radio("Yes")
  click_button "Continue"
end

Then("I should be redirected to zip file upload page") do
  expected_h1("Upload your EU notification files")
end

Then("I should be able to upload valid zip file successfully") do
  page.attach_file("spec/cucumber/test-file.zip")
  click_button "Continue"
  sleep 5
end
