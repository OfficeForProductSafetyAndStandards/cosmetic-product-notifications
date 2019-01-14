class ManualEntryController < ApplicationController
    include Wicked::Wizard

    steps :add_product_name, :add_external_reference, :check_your_answers, :confirmation

    def show
        @notification = Notification.find(session[:notification_id])
        render_wizard
    end

    def update
        @notification = Notification.find(session[:notification_id])

        if !notification_params.nil?
            @notification.update_attributes(notification_params)
        end

        if next_step?(steps.last)
            @notification.submit_notification!
        end

        render_wizard @notification
    end

    def create
        @notification = Notification.create
        session[:notification_id] = @notification.id
        redirect_to wizard_path steps.first
    end

    private

    def notification_params
        params.permit({:notification => [
            :product_name,
            :external_reference
        ]})[:notification]
    end
end
