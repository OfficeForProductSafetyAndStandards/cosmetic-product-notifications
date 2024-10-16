require "nokogiri"

# Adds a custom matcher asserting that a given HTML string contains
# a page title with the given text
module Matchers
  class HaveTitleMatcher
    def initialize(expected_text)
      @expected_text = expected_text
    end

    def matches?(html)
      @html = html
      @head = Nokogiri::HTML(@html).at_css("head")
      @title = @head.at_css("title")
      @title.text.start_with?(@expected_text)
    end

    def failure_message
      if @title
        "expected title to start with ‘#{@expected_text}’, but was ‘#{@title.text}’"
      else
        "expected:\n\n#{@head.to_xhtml(indent: 3)}\n\n ...to contain a title tag"
      end
    end
  end

  def have_title(html)
    HaveTitleMatcher.new(html)
  end
end
