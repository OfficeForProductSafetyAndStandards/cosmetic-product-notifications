module ManualNotificationConcern
  extend ActiveSupport::Concern
  include Wicked::Wizard

  def notification
    if params[:notification_id]
      return Notification.find(params[:notification_id])
    elsif params[:component_id]
      component = Component.find(params[:component_id])
      return component.notification
    end
  end

  def pre_eu_exit?(step = @step)
    post_eu_exit_steps.include?(step) && notification.notified_pre_eu_exit?
  end

  def previous_step(current_step = nil)
    step = super(current_step)
    return previous_step(step) if pre_eu_exit?(step)
    step
  end

  def next_step(current_step = nil)
    step = super(current_step)
    return next_step(step) if pre_eu_exit?(step)
    step
  end
end
