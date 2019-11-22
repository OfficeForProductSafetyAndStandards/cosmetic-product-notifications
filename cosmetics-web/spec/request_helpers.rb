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

# Adds a custom matcher asserting that a given HTML string contains
# a GOV.UK 'Back link' component to the URL path given.
module HaveH1WithTextMatcher
  class HaveH1WithTextMatcher
    def initialize(expected_text)
      @expected_text = expected_text
    end

    def matches?(html)
      @html = html
      @main = Nokogiri::HTML(@html).at_css("main")
      @h1s = @main.css("h1")
      @h1s.length == 1 && @h1s[0].text == @expected_text
    end

    def failure_message
      if @h1s.length > 1
        "More than 1 <h1> element was present: \n\n#{@h1s.collect(&:to_s).join("\n")}"
      elsif @h1s.length == 1
        "expected h1 to contain the text ‘#{@expected_text}’, but was ‘#{@h1s[0].text}’"
      else
        "expected:\n\n#{@main.to_xhtml(indent: 2)}\n\n ...to contain an h1"
      end
    end
  end

  def have_h1_with_text(html)
    HaveH1WithTextMatcher.new(html)
  end
end

RSpec.configure do |config|
  config.include HaveBackLinkToMatcher
  config.include HaveH1WithTextMatcher
end
