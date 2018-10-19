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
    { status: params[:status] } if params[:status].present?
  end

  def query_params
    params.permit(:q, :sort, :direction, :status)
  end

  def get_pretty_id(investigation_id)
    id_string = investigation_id.to_s.rjust(8, '0')
    id_string.insert(4, "-")
  end
end
