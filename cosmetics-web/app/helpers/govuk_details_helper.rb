module GovukDetailsHelper
  # Generates the HTML for the
  # [Details component](https://design-system.service.gov.uk/components/details/)
  # from the GOV.UK Design System.
  #
  # The method name and parameters are camelCased to follow the convention of
  # the Nunjucks macros from the GOV.UK Design System, to make it easier to
  # copy and paste templates from the Prototyping Kit.
  #
  #
  # Implementation based on https://github.com/alphagov/govuk-frontend/blob/master/src/govuk/components/details/
  #
  # rubocop:disable Naming/MethodName, Naming/UncommunicativeMethodParamName, Naming/VariableName
  def govukDetails(summaryText: nil, summaryHtml: nil, text: nil, html: nil, id: nil, open: nil, classes: '', attributes: {})
    attributes.merge!("class" => "govuk-details #{classes}", id: id, "data-module" => "details")
    attributes["open" => "open"] if open

    content_tag('details', attributes) do
      summary = content_tag('summary', class: 'govuk-details__summary') do
        content_tag('span', class: 'govuk-details__summary-text') do
          summaryHtml || summaryText
        end
      end
      content = content_tag('div', class: 'govuk-details__text') do
        html || text || yield
      end

      summary + content
    end
  end
  # rubocop:enable Naming/MethodName, Naming/UncommunicativeMethodParamName, Naming/VariableName
end
