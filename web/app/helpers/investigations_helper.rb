module InvestigationsHelper
  include SearchHelper

  def search_for_investigations(page_size)
    Investigation.full_search(search_query)
                 .paginate(page: params[:page], per_page: page_size)
  end

  def sorting_params
    case params[:sort_by]
    when "newest"
      { created_at: "desc" }
    when "oldest"
      { updated_at: "asc" }
    else
      { updated_at: "desc" }
    end
  end

  def filter_params
    filters = {}
    filters.merge!(get_status_filter)
    filters.merge!(get_assignee_filter)
  end

  def get_status_filter
    return {} if params[:status_open] == params[:status_closed]

    status = if params[:status_open] == "checked"
               { is_closed: false }
             else
               { is_closed: true }
             end
    { must: { term: status } }
  end

  def get_assignee_filter
    assignees = []
    excluded_assignees = []

    if params[:assigned_to_me] == "checked" &&
        params[:assigned_to_someone_else] == "unchecked"
      assignees << current_user.id
    end

    if params[:assigned_to_me] == "unchecked" &&
        params[:assigned_to_someone_else] == "checked" &&
        params[:assigned_to_someone_else_id].blank?
      excluded_assignees << current_user.id
    end

    if params[:assigned_to_me] == "unchecked" &&
        params[:assigned_to_someone_else] == "checked" &&
        params[:assigned_to_someone_else_id].present?
      assignees << params[:assigned_to_someone_else_id]
    end

    if params[:assigned_to_me] == "checked" &&
        params[:assigned_to_someone_else] == "checked" &&
        params[:assigned_to_someone_else_id].present?
      assignees << current_user.id
      assignees << params[:assigned_to_someone_else_id]
    end

    assignee_terms = format_assignee_terms(assignees)
    excluded_assignee_terms = format_assignee_terms(excluded_assignees)
    { should: assignee_terms, must_not: excluded_assignee_terms }
  end

  def format_assignee_terms(assignee_array)
    assignee_array.map do |a|
      { term: { assignee_id: a } }
    end
  end

  def query_params
    set_default_status_filter
    set_default_sort_by_filter
    set_default_assignee_filter
    params.permit(:q, :status_open, :status_closed, :page,
                  :assigned_to_me, :assigned_to_someone_else, :assigned_to_someone_else_id, :sort_by)
  end

  def set_default_status_filter
    params[:status_open] = "checked" if params[:status_open].blank?
  end

  def set_default_sort_by_filter
    params[:sort_by] = "recent" if params[:sort_by].blank?
  end

  def set_default_assignee_filter
    params[:assigned_to_me] = "unchecked" if params[:assigned_to_me].blank?
    params[:assigned_to_someone_else] = "unchecked" if params[:assigned_to_someone_else].blank?
  end
end
