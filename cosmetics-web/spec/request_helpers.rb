
# Adds a custom matcher asserting that a given HTML string contains
# a 'Back link' component to the URL path given.
RSpec::Matchers.define :have_back_link_to do |expected_path|
  match do |actual|
    body = Nokogiri::HTML(actual).at_css("body")
    back_link = body.at_css("a.govuk-back-link")
    back_link && back_link["href"] == expected_path
  end
  failure_message do |actual|
    body = Nokogiri::HTML(actual).at_css("body")
    back_link = body.at_css("a.govuk-back-link")
    if back_link
      "expected a back to #{expected_path}, but was #{back_link['href']}"
    else
      "expected:\n\n#{body.to_xhtml(indent: 3)}\n\n ...to contain a back link using a 'govuk-back-link' class"
    end
  end
end
