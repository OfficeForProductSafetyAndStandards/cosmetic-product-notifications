module WizardConcern
  extend ActiveSupport::Concern
  include Wicked::Wizard

  included do
    helper_method :next_step_path
    before_action :check_minimum_state
    helper_method :model

    rescue_from Wicked::Wizard::InvalidStepError do
      raise ActionController::RoutingError, "Invalid step"
    end
  end

  def yes_no_param(param)
    params.dig(model.model_name.param_key, param)
  end

  def skip_next_steps(steps_to_skip)
    step = @step
    (steps_to_skip + 1).times do
      step = next_step(step)
    end
    jump_to_step(step)
  end

  # Value of the question is either yes or no
  def yes_no_question(param, skip_steps_on: "no", on_skip: nil, on_next_step: nil, steps_to_skip: 1)
    answer = yes_no_param(param)

    if %w[yes no].include? answer
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

  def jump_to_step(step, **params)
    jump_to(step, **params)
    render_next_step model
  end

  def rerender_current_step
    render step
  end

  def next_step_path
    next_wizard_path
  end

  def model
    raise "model method should be overridden"
  end

  def set_notification
    @notification ||= Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_component
    @component = Component.find(params[:component_id])
    @notification = @component.notification

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @notification.is_multicomponent? ? @component.name : "the product"
  end

  # To use helper above, the `BACK_ROUTING` constant needs to be defined in controller.
  # The keys should be current page, the values will be previous page.
  # If the current page has multiple back pages, the value will be hash.
  # In such hash, the key will be back page, the value block. If the block evaluates to
  # true, the corresponding key is used as back page. The first block thet evaluates to true, will be back page
  #
  # Example:
  # `:second_page` has only one back page, `:first_page`, but for `:multiple_back_page`
  # there are 2 pages.
  #
  # BACK_ROUTING = {
  #   second_page: :first_page,
  #   multiple_back_page: {
  #     back_page_one: -> { go_to_one? },
  #     back_page_two: -> { go_to_two? },
  #   }
  # }
  def previous_wizard_path(params = nil)
    route = self.class::BACK_ROUTING[step]
    if route.is_a? Hash
      # find first possible pair that evaluates to true
      route = route.find { |_r, blk| instance_exec(&blk) }
      if route.nil?
        return responsible_person_notification_draft_path(@notification.responsible_person, @notification)
      else
        # use symbol from found route
        route = route.first
      end
    end
    wizard_path(route, params)
  end

  def check_minimum_state
    return unless minimum_state

    set_notification

    if @notification.state_lower_than?(minimum_state)
      redirect_to responsible_person_notification_draft_path(@notification.responsible_person, @notification)
    end
  end

  # This might be overrided in wizard controller
  def minimum_state
    nil
  end
end
