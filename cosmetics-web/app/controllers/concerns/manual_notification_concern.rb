module ManualNotificationConcern
  extend ActiveSupport::Concern
  include Wicked::Wizard

  def notification
    if params[:notification_reference_number]
      Notification.find_by reference_number: params[:notification_reference_number]
    elsif params[:notification_id]
      Notification.find(params[:notification_id])
    elsif params[:component_id]
      component = Component.find(params[:component_id])
      component.notification
    end
  end

  def skip_step?(step = @step)
    post_eu_exit_steps.include?(step) && notification.notified_pre_eu_exit?
  end

  def previous_step(current_step = nil)
    step = super(current_step)
    return previous_step(step) if skip_step?(step)

    step
  end

  def next_step(current_step = nil)
    step = super(current_step)
    return next_step(step) if skip_step?(step)

    step
  end

  def object
    @notification || @component
  end

  def yes_no_param(param)
    return params.dig(:component, param) if @component

    params.dig(:notification, param)
  end

  def skip_next_steps(number_of_steps = 1)
    step = @step
    number_of_steps.times do
      step = next_step(step)
    end
    jump_to(next_step(step))
    render_wizard object
  end

  def yes_no_question(param, yes_is_to_skip, before_skip_callback = nil, before_render_callback = nil, number_of_steps = 1)
    case yes_no_param(param)
    when yes_is_to_skip ? "yes" : "no"
      before_skip_callback&.call
      skip_next_steps(number_of_steps)
    when yes_is_to_skip ? "no" : "yes"
      before_render_callback&.call
      render_wizard object
    else
      object.errors.add param, "Choose an option"
      render step
    end
  end
end
