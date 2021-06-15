module NotificationHelper
  def search_date_filter_group_error_class(*fields)
    error_present = fields.any? do |field|
      @form.errors[field].present?
    end

    error_present ? "govuk-form-group--error" : ""
  end
end
