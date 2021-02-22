require "rails_helper"

RSpec.feature "Search smoke test", type: :feature do 
  before do
  	configure_requests_for_search_domain
  	visit(ENV["ENV_URL"])
    expect(page).to have_css("h1", text: "Search for cosmetic products")
  end

  scenario "sign-in and search notification product as poison center user" do
    visit "/sign-in"
    fill_in_search_credentials

    expect_to_be_on_secondary_authentication_page

    complete_secondary_authentication_with(11222)

    expect(page).to have_css("h1", text: "Search cosmetics products")
    expect(page).to have_xpath("//input[contains(@id,'q')]")

    fill_in("q",with: "Beautify Facial Night Cream")
    click("Search")
    expect(page).to have_content("Beautify Facial Nigth cream")

    find("(//a[contains(.,'Beautify Facial Night Cream')])[1]").click

    expect(page).to have_css("h2",text: "Product details")
    expect(page).to have_css("h2", text: "Ingredients")
   end
end

  def fill_in_search_credentials
    fill_in "Email address", with: "nasiralikhan1982@gmail.com"
    fill_in "Password", with: "Nasir123"
    click_button "Continue"

      expect_to_be_on_secondary_authentication_page
   end

  def complete_secondary_authentication_with(fake_code)
	   expect(page).to have_css("h1", text: "Check your phone")
	   fill_in "Enter security code", with: fake_code
     click_on "Continue"
  end
