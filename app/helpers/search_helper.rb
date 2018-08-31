module SearchHelper
  def search_params_present?
    params[:q].present? || params[:sort].present?
  end

  def search_params
    { query: params[:q], sort: sort_column, direction: sort_direction }
  end
end
