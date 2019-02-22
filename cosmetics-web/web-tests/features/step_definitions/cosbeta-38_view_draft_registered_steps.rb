
Given("I login user as {string}") do |string|
  launch_url(ENV["IntEnv"])
  login(ENV["IntUser"],ENV["IntPassword"])
  sleep 2
end

When("I click on {string}") do |string|
custom_click(string)
end

Then("I should see {string}") do |string|
expect(page).to have_content(string)
end

