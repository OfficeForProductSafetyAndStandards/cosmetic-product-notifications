module SystemTestHelper
  def fill_autocomplete(locator, with:, visible: :not_provided)
    if visible == :not_provided
      fill_in locator, with: "#{with}\n"
    else
      fill_in locator, with: "#{with}\n", visible: visible
    end
  end
end
