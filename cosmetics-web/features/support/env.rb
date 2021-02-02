require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-screenshot/cucumber'
require 'active_support/all'
require 'active_record'


Capybara.default_driver = :selenium
 Capybara.register_driver :selenium do |app|
 options = {
 :js_errors => true,
 :timeout => 3600,
 :debug => true,
 :inspector => true,
 }
 Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

World(Capybara::DSL)
# World(CommonHelpers)

# Capybara.asset_host = 'https://psd-pr-770.london.cloudapps.digital/'