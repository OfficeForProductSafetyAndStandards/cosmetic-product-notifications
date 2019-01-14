# Makes sure that the appropriate fields are present at each stage of
# the manual web form
class Validators::ManualNotificationValidator < ActiveModel::Validator
  def validate(notification)
    if MANUAL_STATE_ORDER.include? notification.aasm_state
      mandatory_attributes = get_mandatory_fields_for_state(notification.aasm_state)

      notification.changed.each do |changed_attribute|
        new_value = notification[changed_attribute]

        if mandatory_attributes.include? changed_attribute
          if new_value.blank?
            notification.errors.add changed_attribute, "must not be empty"
          end
        elsif !new_value.nil?
          notification.errors.add changed_attribute, "cannot be set at this stage"
        end
      end
    end
  end

private

  MANUAL_STATE_ORDER = %w[
        empty
        product_name_added
        draft_complete
        notification_complete
    ].freeze

  MANDATORY_FIELDS = {
      'empty' => %w[aasm_state product_name],
      'product_name_added' => %w[external_reference],
      'draft_complete' => [],
      'notification_complete' => []
  }.freeze

    # Returns a list of mandatory fields for a notification in a state.
    # Validation will fail if any of these attributes are empty, or if
    # updates are made to attributes not in this list.
  def get_mandatory_fields_for_state(state)
    index = MANUAL_STATE_ORDER.index(state)
    completed_states = MANUAL_STATE_ORDER[0, index + 1]

    completed_states.collect { |completed_state|
      MANDATORY_FIELDS[completed_state]
    }.flatten
  end
end
