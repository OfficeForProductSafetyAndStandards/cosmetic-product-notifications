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
    return {} if params[:status_open] == params[:status_closed]

    return { is_closed: false } if params[:status_open] == "checked"

    { is_closed: true }
  end

  def query_params
    set_default_status_filter
    params.permit(:q, :sort, :direction, :status_open, :status_closed)
  end

  def set_default_status_filter
    params[:status_open] = "checked" if params[:status_open].blank?
  end
end
