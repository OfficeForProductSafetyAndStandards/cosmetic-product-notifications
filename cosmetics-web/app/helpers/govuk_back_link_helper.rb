module GovukBackLinkHelper
  # rubocop:disable Naming/MethodName
  def govukBackLink(text: nil, html: nil, href:, classes: "", attributes: {})
    attributes[:class] = "govuk-back-link #{classes}"

    link_to (html || text), href, attributes
  end
  # rubocop:enable Naming/MethodName
end
