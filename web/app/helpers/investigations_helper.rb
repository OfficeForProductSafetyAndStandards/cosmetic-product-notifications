module InvestigationsHelper
  include SearchHelper

  def search_for_investigations(page_size)
    Investigation.full_search(search_query)
                 .paginate(page: params[:page], per_page: page_size)
                 .records
  end

  def sort_column
    (Investigation.column_names + %w[assignee]).include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def filter_params
    filters = {}
    filters.merge(get_status_filter)
  end

  def get_status_filter
    return {} if params[:status_open].blank? && params[:status_closed].blank?
    return {} if params[:status_open] == "checked" && params[:status_closed] == "checked"
    return {} if params[:status_open] == "unchecked" && params[:status_closed] == "unchecked"
    return {status: 'open'} if params[:status_open] == "checked"
    {status: 'closed'}
  end

  def query_params
    handle_status_params
    params.permit(:q, :sort, :direction, :status_open, :status_closed)
  end

  def handle_status_params
    params[:status_open] = "checked" if params[:status_open].blank?
  end

end
