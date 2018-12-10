module SystemTestHelper
  def fill_autocomplete(locator, with:)
    fill_in locator, with: "#{with}\n"
  end
end
