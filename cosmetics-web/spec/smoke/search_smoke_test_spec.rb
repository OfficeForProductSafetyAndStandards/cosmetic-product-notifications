require "rails_helper"

RSpec.feature "Search smoke test" do
  let(:session) { Capybara::Session.new :selenium_headless }
  let(:product_name) { ENV.fetch("SMOKE_PRODUCT_NAME", "THE MASK by WOW facial hydrogel sheet face mask") }

  if ENV["RUN_SMOKE"] == "true"
    scenario "sign-in and search notification product as poison center user" do
      session.visit(ENV["SMOKE_ENV_URL"])
      expect(session).to have_css("h1", text: "Cosmetic products search")

      session.visit "#{ENV['SMOKE_ENV_URL']}/sign-in"
      smoke_fill_in_search_credentials(session)

      expect(session).to have_current_path(/\/two-factor/)
      expect(session).to have_h1("Check your phone")

      attempts = 0
      loop do
        code = get_code.scan(/\d{5}/).first
        smoke_complete_secondary_authentication_with(code, session)
        attempts += 1
        break if session.has_css?("h1", text: "Cosmetic products search")
        break if attempts > 3

        sleep attempts * 10
      end

      expect(session).to have_css("h1", text: "Cosmetic products search")
      expect(session).to have_xpath("//input[contains(@id,'q')]")

      session.fill_in("notification_search_form_q", with: product_name)
      puts session.save_page
      session.click_on("Search")
      expect(session).to have_content(product_name)

      session.find("a", text: product_name).click

      # Poison Centre or OPSS user role view
      expect(session).to have_css("h2", text: "Product details")
      expect(session).to have_css("h2", text: "Ingredients")
    end
  end
end

def smoke_fill_in_search_credentials(session)
  session.fill_in "Email address", with: ENV["SMOKE_SEARCH_USER"]
  session.fill_in "Password", with: ENV["SMOKE_SEARCH_PASSWORD"]
  session.click_button "Continue"

  expect(session).to have_current_path(/\/two-factor/)
  expect(session).to have_h1("Check your phone")
end

def smoke_complete_secondary_authentication_with(fake_code, session)
  expect(session).to have_css("h1", text: "Check your phone")
  session.fill_in "Enter security code", with: fake_code
  session.click_on "Continue"
end

def get_code
  uri = URI(ENV["SMOKE_RELAY_CODE_URL"])

  req = Net::HTTP::Get.new(uri)
  req.basic_auth ENV["SMOKE_RELAY_CODE_USER"], ENV["SMOKE_RELAY_CODE_PASS"]

  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  res = http.request(req)
  res.body
end
