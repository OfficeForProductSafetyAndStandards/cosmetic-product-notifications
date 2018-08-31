module InvestigationsHelper
  include SearchHelper

  def search_for_investigations(page_size)
    Investigation.fuzzy_search(search_params)
                 .paginate(page: params[:page], per_page: page_size)
                 .records
  end

  def sort_column
    (Investigation.column_names + ["assignee"]).include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def filter_params
    params.require(:filter).permit(:status)
  end
end
