module SearchHelper
  def search_params_present?
    params[:q].present? || params[:sort].present?
  end

  def search_params
    { query: params[:q], sort: sort_column, direction: sort_direction, filter: parsed_filter_params }
  end

  def parsed_filter_params
    params[:filter] && filter_params.reject { |_, value| value.blank? }
  end
end
