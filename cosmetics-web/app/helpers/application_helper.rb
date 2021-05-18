module ApplicationHelper
  def page_title(title, errors: false)
    title = "Error: #{title}" if errors
    content_for(:page_title, title)
  end

  # The map_errors parameters can be used to link error messages for multi-answer
  # so they focus on a specific attribute option when clicked.
  # Eg: "map_errors: { colours: :red }" will cause validation errors messages for
  # "colours" in the error summary to link to "#red" instead of to "#colours".
  def error_summary(errors, ordered_attributes = [], map_errors: {})
    return unless errors.any?

    ordered_errors = ActiveSupport::OrderedHash.new
    ordered_attributes.map { |attr| ordered_errors[attr] = [] }

    errors.map do |error|
      next if error.blank?

      href = if map_errors[error.attribute]
               "##{map_errors[error.attribute]}"
             else
               "##{error.attribute}"
             end

      # Errors for attributes that are not included in the ordered list will be
      # added at the end after the errors for ordered attributes.
      if ordered_errors[error.attribute]
        ordered_errors[error.attribute] << { text: error.message, href: href }
      else
        ordered_errors[error.attribute] = [{ text: error.message, href: href }]
      end
    end
    error_list = ordered_errors.values.flatten.compact

    govukErrorSummary(titleText: "There is a problem", errorList: error_list)
  end

  def display_keywords(keywords)
    return if keywords.blank?

    keywords = keywords.split(" ")
    keywords = keywords.join(", ")
    keywords = keywords.gsub(",,", ",")

    "<span class=\"govuk-!-font-weight-bold\">#{keywords},</span>".html_safe
  rescue StandardError
    keywords
  end
end
