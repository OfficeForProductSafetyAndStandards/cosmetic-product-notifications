
module PageMatchers

  def have_h1(text)
    have_selector("h1", text: text)
  end


  # Matcher for items within the [Summary list](https://design-system.service.gov.uk/components/summary-list/) component.
  #
  # Note: currently this expects table markup. However this should be updated to use
  # definition list (`<dd>` and `<dt>`) markup when the template is updated.
  class HaveSummaryItem
    def initialize(key:, value:)
      @key = key
      @value = value
    end

    def matches?(page)
      @page = page
      begin
        @key_element = @page.find("th", text: @key)
        @sibling_element = @key_element.sibling("td", text: @value)
      rescue
        Capybara::ElementNotFound
      end

      @sibling_element
    end

    def failure_message
      if !@key_element
        "Could not find <th> containing ‘#{@key}’"
      elsif !@sibling_element
        "Could not find sibling <td> containing ‘#{@value}’ within #{@key_element.find(:xpath, '..').native}"
      end
    end
  end

  def have_summary_item(key:, value:)
    HaveSummaryItem.new(key: key, value: value)
  end

end
