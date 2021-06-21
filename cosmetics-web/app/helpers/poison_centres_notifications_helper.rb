module PoisonCentresNotificationsHelper
  def search_date_filter_group_error_class(*fields)
    error_present = fields.any? do |field|
      @search_form.errors[field].present?
    end

    error_present ? "govuk-form-group--error" : ""
  end

  def display_keywords
    keywords = @search_form.q
    return if keywords.blank?

    keywords = keywords.split(" ")
    keywords = keywords.join(", ")
    keywords = keywords.gsub(",,", ",")

    " matching keyword(s) <span class=\"govuk-!-font-weight-bold\">#{keywords},</span>".html_safe
  rescue StandardError
    keywords
  end

  def display_filters_informations
    "using filters," if @search_form.valid? && @search_form.date_filter.present?
  end
end
