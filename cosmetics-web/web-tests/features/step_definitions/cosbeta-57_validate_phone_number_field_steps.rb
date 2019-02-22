Given("I am on register field") do
launch_url(ENV["IntEnv"])
logout
find(:xpath,"//a[contains(.,'Create an account')]").click
end

Given("I enter all required fields") do
fill_reg_form
end

When("I enter phone number field with invalid phone number {string}") do |string|
fill_in('mobileNumber', :with => string)
find(:xpath,"//input[@value='Continue']").click
sleep 3
end

Then("I should see error message {string}") do |string|
  expect(page).to have_content('Invalid phone number.')

end