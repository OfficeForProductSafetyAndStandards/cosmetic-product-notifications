module PoisonCentresNotificationsHelper
  INGREDIENTS_SEARCH = "ingredients_search".freeze
  NOTIFICATIONS_SEARCH = "notifications_search".freeze

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
    "using the current filters," if @search_form.valid? && @search_form.filters_present?
  end

  def back_to_ingredients?
    params[:back_to] == INGREDIENTS_SEARCH
  end

  def active_page_class(page)
    if is_current_page(page)
      "class='opss-left-nav__active'".html_safe
    end
  end

  def aria_active(page)
    if is_current_page(page)
      "aria-current='page'".html_safe
    end
  end

  def is_current_page(page)
    case page
    when :notifications_search
      params[:controller] == "poison_centres/notifications_search"
    when :ingredients_search
      params[:controller] == "poison_centres/ingredients_search"
    when :ingredients_list
      params[:controller] == "poison_centres/ingredients"
    end
  end
end
