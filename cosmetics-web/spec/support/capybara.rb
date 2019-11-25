Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { "HTTP_USER_AGENT" => "Capybara" })
end
