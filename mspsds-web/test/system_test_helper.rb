module SystemTestHelper
  def fill_autocomplete(locator, with:, visible: nil)
    fill_in locator, with: "#{with}\n", visible: visible
  end
end
