module Investigations::UserFiltersHelper
  def entities
    User.get_assignees(except: User.current) + Team.all
  end

  def assigned_to(form)
    assigned_to_items = [{ key: "assigned_to_me", value: "checked", unchecked_value: "unchecked", text: "Me" }]
    assignee_teams_with_keys.each do |key, team, name|
      assigned_to_items << { key: key, value: team.id, unchecked_value: "unchecked", text: name }
    end
    assigned_to_items << { key: "assigned_to_someone_else",
                 value: "checked",
                 unchecked_value: "unchecked",
                 text: "Other person or team",
                 conditional: { html: other_assignee(form) } }
  end

  def created_by(form)
    created_by_items = [{ key: "created_by_me", value: "checked", unchecked_value: "unchecked", text: "Me" }]
    creator_teams_with_keys.each do |key, team, name|
      created_by_items << { key: key, value: team.id, unchecked_value: "unchecked", text: name }
    end
    created_by_items << { key: "created_by_someone_else",
                 value: "checked",
                 unchecked_value: "unchecked",
                 text: "Other person or team",
                 conditional: { html: other_creator(form) } }
  end

  def other_assignee(form)
    render "form_components/govuk_select", key: :assigned_to_someone_else_id, form: form,
                  items: entities.map { |e| { text: e.display_name, value: e.id } },
                  label: { text: "Name" }, is_autocomplete: true
  end

  def other_creator(form)
    render "form_components/govuk_select", key: :created_by_someone_else_id, form: form,
                  items: entities.map { |e| { text: e.display_name, value: e.id } },
                  label: { text: "Name" }, is_autocomplete: true
  end
end
