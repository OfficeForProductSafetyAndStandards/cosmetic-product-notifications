module WizardConcern
  extend ActiveSupport::Concern
  include Wicked::Wizard

  included do
    helper_method :next_step_path
    helper_method :model
  end

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

  # Value of the question is either yes or no
  def yes_no_question(param, skip_steps_on: "no", on_skip: nil, on_next_step: nil, steps_to_skip: 1)
    answer = yes_no_param(param)

    if ["yes", "no"].include? answer
      model.save_routing_answer(step, answer)
      if skip_steps_on == answer
        on_skip&.call
        skip_next_steps(steps_to_skip)
      else
        on_next_step&.call
        render_next_step model
      end
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
      rerender_current_step
    end
  end

  # Wicked wizard method names are really misleading, lets create some better names!
  def render_next_step(object)
    render_wizard object
  end

  def jump_to_step(step)
    jump_to(step)
    render_next_step model
  end

  def rerender_current_step
    render step
  end

  def next_step_path
    next_wizard_path
  end

  def model
    # If you want your controller to allow different after_eu steps, override this
    raise "model method should be overridden"
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_component
    @component = Component.find(params[:component_id])
    @notification = @component.notification

    return redirect_to responsible_person_notification_path(@component.notification.responsible_person, @component.notification) if @component&.notification&.notification_complete?

    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the product"
  end

  def previous_wizard_path
    route = self.class::BACK_ROUTING[step]
    if route.is_a? Array
      route = route.find { |r| instance_exec(&self.class::BACK_ROUTING_FUNCTIONS[r]) }
      if route.nil?
        return responsible_person_notification_draft_path(@notification.responsible_person, @notification)
      end
    end
    wizard_path(route)
  end

end
