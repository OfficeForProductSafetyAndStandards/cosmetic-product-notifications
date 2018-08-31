module InvestigationsHelper
  include SearchHelper

  def search_for_investigations(page_size)
    if search_params_present?
      Investigation.fuzzy_search(search_params)
                   .paginate(page: params[:page], per_page: page_size)
                   .records
    else
      Investigation.paginate(page: params[:page], per_page: page_size)
    end
  end

  def sort_column
    (Investigation.column_names + ["assignee"]).include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
