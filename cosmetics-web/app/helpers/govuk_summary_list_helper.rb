module GovukSummaryListHelper
  # rubocop:disable Naming/MethodName
  def govukSummaryList(rows: [], classes: "", attributes: {})
    attributes[:class] = "govuk-summary-list #{classes}"
    content_tag("dl", class: classes) do
      rows.each do |row|
        row = content_tag("div", class: "govuk-summary-list__row") do
          concat content_tag("dt", (row[:key][:text] || row[:key][:html]), class: "govuk-summary-list__key")
          concat content_tag("dd", (row[:value][:text] || row[:value][:html]), class: "govuk-summary-list__value")

          if !row.fetch(:actions, {}).fetch(:items, []).empty?

            actions = content_tag("dd", class: "govuk-summary-list__actions") do
              row[:actions][:items].each do |item|
                concat link_to(item[:text], item[:href])
              end
            end

            concat actions
          end
        end

        concat row
      end
    end
  end
  # rubocop:enable Naming/MethodName
end
