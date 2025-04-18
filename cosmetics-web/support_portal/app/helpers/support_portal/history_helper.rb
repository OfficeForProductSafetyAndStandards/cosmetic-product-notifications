module SupportPortal
  module HistoryHelper
    NOTIFICATION_ACTIONS = {
      "delete": "deletion",
      "undelete": "recovery",
    }.freeze

    NOTIFICATION_ACTIONS_PAST_TENSE = {
      "delete": "deleted",
      "undelete": "recovered",
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

    BUSINESS_TYPES = {
      "limited_company": "Limited Company",
      "sole_trader": "Sole Trader",
      "partnership": "Partnership",
      "other": "Other",
    }.freeze

    USER_ACTIONS = {
      "role": "role change",
      "deactivated_at_set": "deactivation",
      "deactivated_at_unset": "reactivation",
    }.freeze

    USER_ACTIONS_PAST_TENSE = {
      "deactivated_at_set": "deactivated",
      "deactivated_at_unset": "reactivated",
    }.freeze

    def display_action(action)
      case action.item_type
      when "Notification"
        display_notification_action(action)
      when "ResponsiblePerson"
        display_responsible_person_action(action)
      when "User"
        display_user_action(action)
      end
    end

    def display_action_change(action)
      return display_notification_action_details(action) if action.item_type == "Notification"

      return display_responsible_person_action_details(action.object_changes) if action.item_type == "ResponsiblePerson"

      display_user_action_details(action)
    end

    def display_notification_action(action)
      "UKCP number (#{action.item.reference_number || action.item.deleted_notification.reference_number}) #{NOTIFICATION_ACTIONS[action.event.to_sym]}"
    end

    def display_notification_action_details(action)
      "#{action.whodunnit} #{NOTIFICATION_ACTIONS_PAST_TENSE[action.event.to_sym]} UKCP #{action.item.reference_number || action.item.deleted_notification.reference_number}"
    end

    def display_responsible_person_action(action)
      change = action.object_changes.except("updated_at").keys.first

      "RP (#{action.item.name}) #{RESPONSIBLE_PERSON_ACTIONS[change.to_sym]} change"
    end

    def responsible_person_business_type(type)
      return "" if type.blank?

      BUSINESS_TYPES[type.to_sym] || type.titleize
    end

    def display_responsible_person_action_details(object_changes)
      object_changes = object_changes.except("updated_at")
      account_type_change = object_changes.keys.first == "account_type"
      address_change = %w[address_line_1 address_line_2 city county postal_code].include?(object_changes.keys.first)

      changes = if address_change
                  %w[address_line_1 address_line_2 city county postal_code].map { |key|
                    object_changes[key]
                  }.compact
                else
                  object_changes.values
                end

      if account_type_change
        changes.map { |change|
          next unless change.is_a?(Array) && change.size == 2

          "Change from: #{responsible_person_business_type(change[0])}<br>To: #{responsible_person_business_type(change[1])}"
        }.compact.join("<br>")
      else
        changes.map { |change|
          next unless change.is_a?(Array) && change.size == 2

          from_value = change[0].presence || "<em>Empty</em>"
          to_value = change[1].presence || "<em>Empty</em>"
          "Change from: #{from_value}<br>To: #{to_value}"
        }.compact.join("<br>")
      end
    end

    def display_user_action(action)
      change = action.object_changes.except("updated_at").keys.first
      change_to = action.object_changes.except("updated_at")[change].last

      change += change_to.nil? ? "_unset" : "_set" if change == "deactivated_at"

      "User (#{action.object['email']}) #{USER_ACTIONS[change.to_sym]}"
    end

    def display_user_action_details(action)
      change_key = action.object_changes.except("updated_at").keys.first
      changes = action.object_changes.except("updated_at").values

      if change_key == "deactivated_at"
        change_key += action.object_changes.except("updated_at")[change_key].last.nil? ? "_unset" : "_set"
        "#{action.whodunnit} #{USER_ACTIONS_PAST_TENSE[change_key.to_sym]} user #{action.object['email']}"
      else
        changes.map { |change_values|
          "Change from: #{role_type(change_values[0])}<br>To: #{role_type(change_values[1])}"
        }.join("<br>")
      end
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
