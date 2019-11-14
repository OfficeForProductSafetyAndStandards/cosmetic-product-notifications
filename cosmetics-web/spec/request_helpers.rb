require "nokogiri"

# Adds a custom matcher asserting that a given HTML string contains
# a GOV.UK 'Back link' component to the URL path given.
module HaveBackLinkToMatcher
  class HaveBackLinkToMatcher
    def initialize(expected_path)
      @expected_path = expected_path
    end

    def matches?(html)
      @html = html
      @body = Nokogiri::HTML(@html).at_css("body")
      @back_link = @body.at_css("a.govuk-back-link")
      @back_link && @back_link["href"] == @expected_path
    end

    def failure_message
      if @back_link
        "expected a back link to #{@expected_path}, but was #{@back_link['href']}"
      else
        "expected:\n\n#{@body.to_xhtml(indent: 3)}\n\n ...to contain a back link using a 'govuk-back-link' class"
      end
    end
  end

  def have_back_link_to(html)
    HaveBackLinkToMatcher.new(html)
  end
end

RSpec.configure do |config|
  config.include HaveBackLinkToMatcher
end
