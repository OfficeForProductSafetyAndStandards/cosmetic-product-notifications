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

  def exclude_params
    excludes = {}
    excludes.merge!({assignee_id: "4e7ad61f-9c39-4cad-b648-b4ae18000636"})
  end

  def filter_params
    filters = {}
    filters.merge!(get_status_filter)
    filters.merge!(get_assignee_filter)
  end

  def get_status_filter
    return {} if params[:status_open] == params[:status_closed]
    return { status: 'open' } if params[:status_open] == "checked"
    { status: 'closed' }
  end

  def get_assignee_filter
    if params[:assigned_to_me] == "unchecked"
      if params[:assigned_to_someone_else] == "unchecked"
        return {}
      elsif params[:assigned_to_someone_else_name].nil?
        return {} #TODO: exclude me
      else
        return {assignee_id: params[:assigned_to_someone_else_name]}
      end
    else
      if params[:assigned_to_someone_else] == "unchecked"
        return {assignee_id: current_user.id}
      elsif params[:assigned_to_someone_else_name].nil?
        return {}
      else
        return {} #TODO: user or me
      end
    end
    {}
  end

  def query_params
    set_default_status_filter
    set_default_assignee_filter
    params.permit(:q, :sort, :direction, :status_open, :status_closed,
                  :assigned_to_me, :assigned_to_someone_else, :assigned_to_someone_else_name)
  end

  def set_default_status_filter
    params[:status_open] = "checked" if params[:status_open].blank?
  end

  def set_default_assignee_filter
    params[:assigned_to_me] = "unchecked" if params[:assigned_to_me].blank?
    params[:assigned_to_someone_else] = "unchecked" if params[:assigned_to_someone_else].blank?
  end
end
