module ApplicationHelper
  def page_title(title, errors: false)
    title = "Error: #{title}" if errors
    content_for(:page_title, title)
  end

  def error_summary(errors, ordered_attributes = [])
    return unless errors.any?

    ordered_errors = ActiveSupport::OrderedHash.new
    ordered_attributes.map { |attr| ordered_errors[attr] = [] }

    errors.map do |attribute, error|
      next if error.blank?

      # Errors for attributes that are not included in the ordered list will be
      # added at the end after the errors for ordered attributes.
      if ordered_errors[attribute]
        ordered_errors[attribute] << { text: error, href: "##{attribute}" }
      else
        ordered_errors[attribute] = [{ text: error, href: "##{attribute}" }]
      end
    end
    error_list = ordered_errors.values.flatten.compact

    govukErrorSummary(titleText: "There is a problem", errorList: error_list)
  end
end
