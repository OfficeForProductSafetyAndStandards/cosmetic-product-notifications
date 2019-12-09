require "nokogiri"

# Adds a custom matcher asserting that a single <h1> element
# contains the given text.
module Matchers
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
