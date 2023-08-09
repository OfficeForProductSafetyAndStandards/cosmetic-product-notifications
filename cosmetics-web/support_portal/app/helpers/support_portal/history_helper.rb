module SupportPortal
  module HistoryHelper
    NOTIFICATION_ACTIONS = {
      "delete": "Deletion",
      "undelete": "Recovery",
    }.freeze

    NOTIFICATION_ACTIONS_PAST_TENSE = {
      "delete": "Deleted",
      "undelete": "Recovered",
    }.freeze

    RESPONSIBLE_PERSON_ACTIONS = {
      "name": "Name",
      "account_type": "Business type",
      "address_line_1": "Address",
      "address_line_2": "Address",
      "postal_code": "Address",
      "county": "Address",
      "city": "Address",
    }.freeze

    def display_action(action)
      case action.item_type
      when "Notification"
        display_notification_action(action)
      when "ResponsiblePerson"
        display_responsible_person_action(action.object_changes)
      end
    end

    def display_action_change(action)
      return display_notification_action_details(action) if action.item_type == "Notification"

      display_responsible_person_action_details(action.object_changes)
    end

    def display_responsible_person_action(object_changes)
      change = object_changes.except("updated_at").keys.first

      "RP (#{RESPONSIBLE_PERSON_ACTIONS[change.to_sym]}) Change"
    end

    def display_responsible_person_action_details(object_changes)
      changes = object_changes.except("updated_at").values

      changes.map { |change|
        "Change from: #{change[0]}<br>To: #{change[1]}"
      }.join("<br>")
    end

    def display_notification_action(action)
      "UKCP Number (#{action.item.reference_number}) #{NOTIFICATION_ACTIONS[action.event.to_sym]}"
    end

    def display_notification_action_details(action)
      "#{action.whodunnit} #{NOTIFICATION_ACTIONS_PAST_TENSE[action.event.to_sym]} UKCP (#{action.item.reference_number})"
    end

    def sorting_params(sort_by, params)
      if params[:sort_by] == sort_by
        params[:sort_direction] = set_sort_direction(params[:sort_direction])
      else
        params[:sort_by] = sort_by
        params[:sort_direction] = "asc"
      end

      params
    end

    def sort_indicator_direction(sort_by, params)
      return "none" if params[:sort_by] != sort_by || params[:sort_direction].blank?

      "#{params[:sort_direction]}ending"
    end

    def set_sort_direction(starting_sort_direction)
      starting_sort_direction == "desc" ? "asc" : "desc"
    end
  end
end
