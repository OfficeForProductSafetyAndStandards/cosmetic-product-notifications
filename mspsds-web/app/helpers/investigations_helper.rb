module InvestigationsHelper
  include SearchHelper

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
    return { should: [], must_not: [] } if no_boxes_checked
    return { should: [], must_not: compute_excluded_terms } if assignee_filter_exclusive

    { should: compute_included_terms, must_not: [] }
  end

  def no_boxes_checked
    no_people_boxes_checked = params[:assigned_to_me] == "unchecked" && params[:assigned_to_someone_else] == "unchecked"
    no_team_boxes_checked = teams_with_keys.all? { |key, _t, _n| query_params[key].blank? }
    no_people_boxes_checked && no_team_boxes_checked
  end

  def assignee_filter_exclusive
    params[:assigned_to_someone_else] == "checked" && params[:assigned_to_someone_else_id].blank?
  end

  def compute_excluded_terms
    # After consultation with designers we chose to ignore teams who are not selected in blacklisting
    excluded_assignees = []
    excluded_assignees << User.current.id if params[:assigned_to_me] == "unchecked"
    format_assignee_terms(excluded_assignees)
  end

  def compute_included_terms
    # If 'Me' is not checked, but one of current users teams is selected, we don't exclude current user from it
    assignees = checked_team_assignees
    assignees.concat(someone_else_assignees)
    assignees << User.current.id if params[:assigned_to_me] == "checked"
    format_assignee_terms(assignees.uniq)
  end

  def checked_team_assignees
    assignees = []
    teams_with_keys.each do |key, team, _n|
      assignees.concat(assignee_ids_from_team(team)) if query_params[key].present?
    end
    assignees
  end

  def someone_else_assignees
    return [] unless params[:assigned_to_someone_else] == "checked"

    team = Team.find_by(id: params[:assigned_to_someone_else_id])
    team.present? ? assignee_ids_from_team(team) : [params[:assigned_to_someone_else_id]]
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
                  teams_with_keys.map { |key, _t, _n| key })
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
        items: [
            {
                text: "Cases",
                href: investigations_path
            },
            {
                text: @investigation.pretty_description
            }
        ]
    }
  end

  def teams_with_keys
    User.current.teams.map.with_index do |team, index|
      # key, team, name
      [
        "assigned_to_team_#{index}".to_sym,
        team,
        User.current.teams.count > 1 ? team.name : "My team"
      ]
    end
  end

  def assignee_ids_from_team(team)
    [team.id] + team.users.map(&:id)
  end

  def suggested_previous_assignees
    all_past_assignees = @investigation.past_assignees + @investigation.past_teams
    return [] if all_past_assignees.empty? || all_past_assignees == [User.current]

    all_past_assignees || []
  end
end
