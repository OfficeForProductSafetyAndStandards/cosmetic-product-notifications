Given('I login as business user') do
   sign_in_as_business
end

Then('I should be navigated to dashboard page') do
   expect(page).to have_selector("h1", text: 'Your cosmetic products')
  end

Then('I should be redirected to dashboard page') do
   expect(page).to have_selector("h1", text: 'Your cosmetic products')
end


When('I click add cosmetics product') do
  click_on('Add cosmetics products')
end

When('I select notified in EU {string}') do |string|
 choose(string, visible: false)
 click_button "Continue"
end

When('I select are you likely to notify in EU {string}') do |string|
 choose(string, visible: false)
 click_button "Continue"
end


When('I select {string} notified in EU') do |string|
   answer_was_eu_notified_with(string)
end

When('I select {string}') do |string|
 choose(string, visible: false)
 click_button "Continue"
 select_manual_notification_prebexit_or_post_brexit('Yes')
end


Then('I should be able to notify product manually') do
enter_product_name("test")
notify_post_brexit
 
end

Then('I should be able to notify product {string}') do |string|
 enter_product_name(string)
 notify_product('post')
end

Then('I should be able to notify {string} product {string}') do |string, string2|
  enter_product_name(string2)
 notify_product(string)
end

Then('I should be able to see the entered details in check your answer page') do
  
end

When('I select I have zip file {string}') do |string|
  expected_h1('EU notification ZIP files')
  select_radio('Yes')
  click_button "Continue"
end

Then('I should be redirected to zip file upload page') do
 expected_h1("Upload your EU notification files")

end

Then('I should be able to upload valid zip file successfully') do
 page.attach_file('spec/cucumber/test-file.zip')
 click_button "Continue"
 sleep 5

 
end