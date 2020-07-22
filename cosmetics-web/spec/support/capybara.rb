Capybara.register_driver :rack_test do |app|
  # Capybara::RackTest::Driver.new(app, headers: { "HTTP_USER_AGENT" => "Capybara" })
  Capybara::RackTest::Driver.new(app, respect_data_method: true, redirect_limit: 6)
end
