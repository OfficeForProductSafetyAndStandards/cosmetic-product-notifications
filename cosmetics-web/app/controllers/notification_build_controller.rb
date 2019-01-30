class NotificationBuildController < ApplicationController
  include Wicked::Wizard

  steps :add_product_name, :add_external_reference, :is_imported, :add_import_country, :single_or_multi_component

  before_action :set_notification

  def show
    render_wizard
  end

  def update
    case step
    when :single_or_multi_component
      if params[:single_or_multi_component] == 'single'
        @notification.components.build
        @notification.save
        redirect_to new_component_build_path(@notification.components.first)
      else
        # TODO COSBETA-10 Implement multiple components
        @notification.components.build
        render_wizard @notification
      end
    when :is_imported
      case params['is_imported']
      when "true"
        render_wizard @notification
      when "false"
        @notification.import_country = nil
        @notification.add_import_country
        jump_to :single_or_multi_component
        render_wizard @notification
      when ""
        @notification.errors.add :import_country, "Must not be nil"
        render step
      end
    when :add_import_country
      @notification.update(notification_params)
      if @notification.import_country.blank?
        @notification.errors.add :import_country, "Must not be blank"
        render step
      else
        render_wizard @notification
      end
    else
      @notification.update(notification_params)
      render_wizard @notification
    end    
  end

  def new
    redirect_to wizard_path(steps.first, notification_id: @notification.id)
  end

  def finish_wizard_path
    edit_notification_path(@notification)
  end

private

  def notification_params
    params.require(:notification).permit(:product_name, :external_reference, :is_imported, :import_country)
  end

  def set_notification
    @notification = Notification.find(params[:notification_id])
  end
end
