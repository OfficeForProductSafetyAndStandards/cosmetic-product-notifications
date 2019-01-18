# Makes sure that the appropriate fields are present at each stage of
# the manual web form
class Validators::ManualNotificationValidator < ActiveModel::Validator
  def validate(notification)
    mandatory_attributes = mandatory_attributes(notification)

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

  private

  MANDATORY_ATTRITBUTES_BY_STATE = [
    %w[state product_name],
    %w[external_reference],
    [],
    []
  ]

  def mandatory_attributes(notification)
    state = notification.state
    output = []
    i = 0
    while i <= Notification.states[state]
      output.push(*MANDATORY_ATTRITBUTES_BY_STATE[i])
      i += 1
    end
    output
  end
end
