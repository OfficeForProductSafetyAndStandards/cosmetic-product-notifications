module SearchHelper
  def set_search_params
    @search = SearchParams.new(query_params)
  end

  def search_params
    { query: params[:q], sort: sort_column, direction: sort_direction }
  end

  def search_query
    query = params[:q] if params[:q].present?
    filters = filter_params
    sorting = sorting_params
    ElasticsearchQuery.new(query, filters, sorting)
  end

  def query_params
    params.permit(:q, :sort, :direction)
  end

  def sorting_params
    # Default empty sort params. To be overridden by the controller.
    # { "#{sort_column}": sort_direction }
  end

  def filter_params
    # Default empty filter params. To be overridden by the controller.
  end
end
