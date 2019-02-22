Bundler.require
require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-screenshot/cucumber'
require 'active_support/all'
require 'active_record'
require_rel '../../lib'
require 'dotenv'



Capybara.configure do |config|

 config.default_driver = :chrome
 config.default_max_wait_time = 15
end

# Capybara.run_server = false


Capybara.run_server = false
# Set default driver as Selenium
Capybara.default_driver = :selenium
 Capybara.register_driver :selenium do |app|
 options = {
 :js_errors => true,
 :timeout => 3600,
 :debug => true,
 :inspector => true
 }
 Capybara::Selenium::Driver.new(app, :browser => :firefox)
end


# Capybara.default_driver = :headless_chrome
# Capybara.register_driver :headless_chrome do |app|
#    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
#    chromeOptions:{
#     args: ["--headless", "--disable-gpu", "--window-size=1920,1080", "--no-sandbox"]
#     # binary: "/usr/bin/google-chrome-stable"
#    }

# #  chromeOptions: {args: %w(headless disable-gpu)}
#    )

#    Capybara::Selenium::Driver.new(app,
#                                   browser: :chrome,
#                                  desired_capabilities: capabilities)
#  end


#Set default selector as css
Capybara.default_selector = :css

Capybara.default_max_wait_time = 15 # seconds

#Syncronization related settings
module Helpers
  def without_resynchronize
    page.driver.options[:resynchronize] = false
    yield
    page.driver.options[:resynchronize] = true
  end
end
World(Capybara::DSL, Helpers)
World(CommonHelpers)

