class ResponsiblePersons::Wizard::NotificationProductKitController < SubmitApplicationController
  include Wicked::Wizard
  include CountriesHelper
  include WizardConcern


  steps :is_mixed,
        :is_hair_dye, # only for multicomponent - at least code says so
        :is_ph_between_3_and_10, # only for multicomponent - at least code says so
        :ph_range, # only for mixed
        :completed

  before_action :set_notification

  def show
    case step
    when :completed
      @notification.update_state('ready_for_components') if @notification.details_complete?
      render 'responsible_persons/wizard/completed'
    else
      render_wizard
    end
  end

  def update
    case step
    when :is_mixed
      update_is_mixed
    when :is_hair_dye
      update_is_hair_dye
    when :is_ph_between_3_and_10
      update_is_ph_between_3_and_10_step
    else
      if @notification.update_with_context(notification_params, step)
        render_next_step @notification
      else
        rerender_current_step
      end
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  private

  def update_is_mixed
    if @notification.update_with_context(notification_params, step)
      unless @notification.components_are_mixed
        clear_ph_range
        jump_to(:completed)
      end
      render_next_step @notification
    else
      rerender_current_step
    end
  end

  def update_is_hair_dye
    yes_no_question(:is_hair_dye, skip_steps_on: "yes")
  end

  def update_is_ph_between_3_and_10_step
    yes_no_question(:is_ph_between_3_and_10, on_skip: method(:clear_ph_range))
  end

  def clear_ph_range
    @notification.update(ph_min_value: nil, ph_max_value: nil)
  end

  def notification_params
    params.fetch(:notification, {})
      .permit(
        :components_are_mixed,
        :ph_min_value,
        :ph_max_value,
      )
  end

  def model
    @notification
  end
end
