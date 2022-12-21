module PageMatchers
  def have_h1(text)
    have_selector("h1", text:, exact_text: true)
  end

  # Matcher for items within the [Summary list](https://design-system.service.gov.uk/components/summary-list/) component.
  #
  # Works with both:
  # - Old table markup (`<th>` and `<td>`).
  # - New definition list markup (`<dt>` and `<dd>`).
  class HaveSummaryItem
    def initialize(key:, value:)
      @key = key
      @value = value
    end

    def matches?(page)
      @page = page
      begin
        @key_element = @page.find("th, dt", text: @key, exact_text: true)
        @sibling_element = @key_element.sibling("td, dd", text: @value, exact_text: true)
      rescue StandardError
        Capybara::ElementNotFound
      end

      @sibling_element
    end

    def failure_message
      if !@key_element
        "Could not find <th> or <dt> containing ‘#{@key}’ within #{@page.html}"
      elsif !@sibling_element
        "Could not find sibling <td> or <dd> containing ‘#{@value}’ within #{@key_element.find(:xpath, '..').native}"
      end
    end

    def failure_message_when_negated
      if !@key_element
        "Should not find <th> or <dt> containing ‘#{@key}’ within #{@page.html}, but present"
      elsif !@sibling_element
        "Should not find sibling <td> or <dd> containing ‘#{@value}’ within #{@key_element.find(:xpath, '..').native}, but present"
      else
        "Should not find sibling <td> or <dd> containing ‘#{@key}’, but present"
      end
    end
  end

  def have_summary_item(key:, value:)
    HaveSummaryItem.new(key:, value:)
  end
end
