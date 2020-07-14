module ApplicationHelper
  def page_title(title, errors: false)
    title = "Error: #{title}" if errors
    content_for(:page_title, title)
  end

  def error_summary(errors)
    return unless errors.any?

    error_list = errors.map { |attribute, error| error ? { text: error, href: "##{attribute}" } : nil }.compact
    govukErrorSummary(titleText: "There is a problem", errorList: error_list)
  end
end
