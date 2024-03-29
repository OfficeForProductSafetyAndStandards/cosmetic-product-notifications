module PoisonCentres::NotificationsHelper
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
    "<span class=\"opss-filter-txt\">using the current filters,</span>".html_safe if @search_form.valid? && @search_form.filters_present?
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
    end
  end

  def ingredient_search_option(label, value)
    selected = params[:group_by] == value ? "selected=\"selected\"" : ""
    "<option value=\"#{value}\" #{selected}>#{label}</option>".html_safe
  end

  def responsible_person_search_option(label, value)
    selected = params[:sort_by] == value ? "selected=\"selected\"" : ""
    "<option value=\"#{value}\" #{selected}>#{label}</option>".html_safe
  end

  def group_by_responsible_person?
    params[:ingredient_search_form] && params[:ingredient_search_form][:group_by] == OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC
  end
end
