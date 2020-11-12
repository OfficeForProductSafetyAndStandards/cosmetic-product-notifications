# Trigger questions are per componenent
class ResponsiblePersons::Wizard::TriggerQuestionsController < SubmitApplicationController
  include Wicked::Wizard
  include CpnpNotificationTriggerRules
  include TriggerRulesHelper

  steps :select_ph_range, :ph

  before_action :set_component

  def show
    render_wizard
  end

  def update
    case step
    when :select_ph_range
      update_component_ph_range
    when :ph
      update_component_ph
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

private

  def finish_wizard_path
    if @component.notification.is_multicomponent?
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_new_component)
    else#if @component.notification.was_notified_before_eu_exit?
      edit_responsible_person_notification_path(@component.notification.responsible_person, @component.notification)
    # else
    #   responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_product_image)
    end
  end

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the cosmetic product"
  end

  def update_component_ph_range
    return re_render_step unless @component.update_with_context(ph_param, :ph)

    if @component.ph_range_not_required?
      update_notification_state
      redirect_to finish_wizard_path
    else
      redirect_to wizard_path(:ph)
    end
  end

  def update_component_ph
    if @component.update_with_context(component_ph_attributes, :ph_range)
      update_notification_state
      redirect_to finish_wizard_path
    else
      re_render_step
    end
  end

  def update_notification_state
    # if @component.notification.was_notified_before_eu_exit?
      @component.notification.components_completed_and_product_image_not_needed!
    # end
  end

  def component_ph_attributes
    params.fetch(:component, {}).permit(:minimum_ph, :maximum_ph)
  end

  def re_render_step
    render step
  end

  def ph_param
    { ph: params.fetch(:component, {})[:ph] }
  end
end
