module InvestigationsHelper
  include SearchHelper
  include UserService

  def search_for_investigations(page_size = Investigation.count)
    result = Investigation.full_search(search_query)
    result.paginate(page: params[:page], per_page: page_size)
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

      teams_with_keys.each do |team_with_key|
        if query_params[team_with_key[:key]].blank?
          team = team_with_key[:team]
          excluded_assignees = assignee_list_with_team(excluded_assignees, team)
        end
      end
    end

    if params[:assigned_to_me] == "unchecked" &&
        params[:assigned_to_someone_else] == "checked" &&
        params[:assigned_to_someone_else_id].present?
      assignees << params[:assigned_to_someone_else_id]
      team = Team.find_by(id: params[:assigned_to_someone_else_id])
      if team.present?
        assignees = assignee_list_with_team(assignees, team)
      end
    end

    if params[:assigned_to_me] == "checked" &&
        params[:assigned_to_someone_else] == "checked" &&
        params[:assigned_to_someone_else_id].present?
      assignees << current_user.id
      assignees << params[:assigned_to_someone_else_id]
    end

    teams_with_keys.each do |team_with_key|
      if query_params[team_with_key[:key]].present?
        team = team_with_key[:team]
        assignees = assignee_list_with_team(assignees, team)
      end
    end

    assignee_terms = format_assignee_terms(assignees)
    excluded_assignee_terms = format_assignee_terms(excluded_assignees)
    { should: assignee_terms, must_not: excluded_assignee_terms }
  end

  def format_assignee_terms(assignee_array)
    assignee_array.map do |a|
      { term: { assignable_id: a } }
    end
  end

  def query_params
    set_default_status_filter
    set_default_sort_by_filter
    set_default_assignee_filter
    params.permit(:q, :status_open, :status_closed, :page,
                  :assigned_to_me, :assigned_to_someone_else, :assigned_to_someone_else_id, :sort_by,
                  teams_with_keys.map{|t|t[:key]})
  end

  def export_params
    query_params.except(:page)
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

  def build_breadcrumb_structure
    {
      ancestors: [
        {
          name: "Cases",
          path: investigations_path
        }
      ],
      current: {
        name: @investigation.pretty_description
      }
    }
  end

  def teams_with_keys
    current_user.teams.map.with_index do |team, index|
      {
        key: "assigned_to_team_#{index}".to_sym,
        team: team
      }
    end
  end

  def assignee_list_with_team(list, team)
    list << team.id
    team.users.each do |member|
      list << member.id
    end
    list
  end
end
