require "rails_helper"

RSpec.describe "Search smoke test" do

  let(:session) { Capybara::Session.new :mechanize }
  let(:product_name) { ENV.fetch("SMOKE_PRODUCT_NAME", "THE MASK by WOW facial hydrogel sheet face mask") }

  scenario "sign-in and search notification product as poison center user" do
    session.visit(ENV["SMOKE_ENV_URL"])
    expect(session).to have_css("h1", text: "Search for cosmetic products")

    session.visit "#{ENV["SMOKE_ENV_URL"]}/sign-in"
    fill_in_search_credentials(session)

    expect(session).to have_current_path(/\/two-factor/)
    expect(session).to have_h1("Check your phone")

    attempts = 0
    loop do
      code = get_code.scan(/\d{5}/).first
      complete_secondary_authentication_with(code, session)
      attempts += 1
      break if session.has_css?("h1", text: "Search cosmetic products")
      break if attempts > 3
      sleep attempts * 10
    end

    expect(session).to have_css("h1", text: "Search cosmetic products")
    expect(session).to have_xpath("//input[contains(@id,'q')]")

    session.fill_in("q",with: product_name)
    puts session.save_page
    session.click_on("Search")
    expect(session).to have_content(product_name)

    session.find("a", text: product_name).click

    expect(session).to have_css("h2",text: "Product details")
    expect(session).to have_css("h2", text: "Ingredients")
   end
end

def fill_in_search_credentials(session)
  session.fill_in "Email address", with: ENV["SMOKE_SEARCH_USER"]
  session.fill_in "Password", with: ENV["SMOKE_SEARCH_PASSWORD"]
  session.click_button "Continue"

  expect(session).to have_current_path(/\/two-factor/)
  expect(session).to have_h1("Check your phone")
end

def complete_secondary_authentication_with(fake_code, session)
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
