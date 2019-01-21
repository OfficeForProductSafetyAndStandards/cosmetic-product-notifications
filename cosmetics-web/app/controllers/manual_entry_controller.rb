class ManualEntryController < ApplicationController
  include Wicked::Wizard

  steps :add_product_name, :add_external_reference, :check_your_answers

  def show
    @notification = Notification.find(params[:notification_id])
    render_wizard
  end

  def update
    @notification = Notification.find(params[:notification_id])

    if step == steps.last
      @notification.submit_notification!
    elsif !notification_params.nil?
      @notification.update(notification_params)
    end

    render_wizard @notification
  end

  def create
    @notification = Notification.create
    redirect_to wizard_path(steps.first, notification_id: @notification.id)
  end

  def confirmation
    @notification = Notification.find(params[:notification_id])
  end

  def finish_wizard_path
    @notification = Notification.find(params[:notification_id])
    notification_path(@notification) + '/confirmation'
  end

private

  def notification_params
    params.require(:notification).permit(:product_name, :external_reference)
  end
end
