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
      next if error.blank? || error.message.blank?

      href = if map_errors[error.attribute]
               map_errors[error.attribute]
             else
               field = error.base[error.attribute]
               if field.respond_to?(:first_error_field) && field.first_error_field.present?
                 "#{error.attribute}_#{field.first_error_field}"
               else
                 error.attribute
               end
             end

      href = "##{href}"

      # Errors for attributes that are not included in the ordered list will be
      # added at the end after the errors for ordered attributes.
      if ordered_errors[error.attribute]
        ordered_errors[error.attribute] << { text: error.message, href: }
      else
        ordered_errors[error.attribute] = [{ text: error.message, href: }]
      end
    end
    error_list = ordered_errors.values.flatten.compact

    govukErrorSummary(titleText: "There is a problem", errorList: error_list)
  end

  def reference_number_for_display(notification)
    sprintf("<abbr>UKCP</abbr>-%08d", notification.reference_number).html_safe
  end

  def wrap_summary_address(address_array)
    address_array.join("<span class=\"govuk-visually-hidden\">,</span><br />").html_safe
  end

  # def error_id(search_form, attribute, part)
  #   if (attr = search_form[attribute]).is_a?(GovUK::DateFromForm::IncompleteDate)
  #     if attr.error_fields.present? && attr.error_fields.keys.first == part
  #       attribute
  #     elsif attr.error_fields.blank? && search_form.errors[attribute].present? && part == :day
  #       attribute
  #     end
  #   elsif attr.is_a? Date
  #     if search_form.errors[attribute].present? && part == :day
  #       attribute
  #     end
  #   end
  # end


  def error_class(search_form, attribute, part)
    if (attr = search_form[attribute]).is_a? GovUK::DateFromForm::IncompleteDate
      if attr.error_fields.present?
        search_form.errors[attribute].present? ? "govuk-input--error".html_safe : ""
        if attr.error_fields.key? part
          "govuk-input--error".html_safe
        end
      else
        search_form.errors[attribute].present? ? "govuk-input--error".html_safe : ""
      end
    else
      search_form.errors[attribute].present? ? "govuk-input--error".html_safe : ""
    end
  end
end
