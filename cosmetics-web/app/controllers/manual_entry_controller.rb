class ManualEntryController < ApplicationController
  include Wicked::Wizard

  steps :add_product_name, :add_external_reference

  before_action :set_notification
  skip_before_action :set_notification, only: [:create]

  def show
    render_wizard
  end

  def update
    @notification.update(notification_params)
    render_wizard @notification
  end

  def create
    @notification = Notification.create
    redirect_to wizard_path(steps.first, notification_id: @notification.id)
  end

  def finish_wizard_path
    edit_notification_path(@notification)
  end

private

  def notification_params
    params.require(:notification).permit(:product_name, :external_reference)
  end

  def set_notification
    @notification = Notification.find(params[:notification_id])
  end
end
