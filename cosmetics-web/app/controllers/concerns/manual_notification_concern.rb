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

  def yes_no_param(param)
    params.dig(model.model_name.param_key, param)
  end

  def skip_next_steps(steps_to_skip)
    step = @step
    steps_to_skip.times do
      step = next_step(step)
    end
    jump_to(next_step(step))
    render_wizard model
  end

  def yes_no_question(param, no_is_to_skip: true, before_skip: nil, before_render: nil, steps_to_skip: 1)
    case yes_no_param(param)
    when no_is_to_skip ? "no" : "yes"
      before_skip&.call
      skip_next_steps(steps_to_skip)
    when no_is_to_skip ? "yes" : "no"
      before_render&.call
      render_wizard model
    else

      error_message = case param
      when :is_hair_dye
        "Select yes if the product contains a hair dye"
      when :is_ph_between_3_and_10
        "Select the pH range of the product when mixed as instructed"
      when :contains_special_applicator
        "Select yes if #{model.component_name} comes in an applicator"
      when :contains_cmrs
        "Select yes if #{model.component_name} contains category 1A or 1B CMRs"
      when :contains_nanomaterials
        "Select yes if #{model.component_name} contains nanomaterials"
      else
        "Select an option"
      end

      model.errors.add param, error_message
      render step
    end
  end

  def post_eu_exit_steps
    # If you want your controller to allow different post_eu steps, override this
    []
  end

  def model
    # If you want your controller to allow different post_eu steps, override this
    raise "model method should be overridden"
  end
end
