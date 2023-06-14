module SupportPortal
  class NotificationsController < ApplicationController
    before_action :set_notification, only: %i[show delete undelete]
    before_action :set_notification_search_params, except: %i[index]

    # GET /
    def index
      @notification_search = NotificationSearch.new
    end

    # GET /search
    def search
      return redirect_to notifications_path unless params[:notification_search].present?

      @notification_search = NotificationSearch.new(notification_search_params)

      if @notification_search.valid?
        notifications = @notification_search.search
        @records_count = notifications.size
        @pagy, @records = pagy(notifications)
      else
        render :index
      end
    end

    # GET /:id
    def show
      @history = @notification.is_a?(::DeletedNotification) ? @notification.notification.versions_with_name : @notification.versions_with_name
    end

    # DELETE /:id/delete
    def delete
      reference_number = @notification.reference_number
      @notification.soft_delete!
      redirect_to notification_path(reference_number, notification_search: @notification_search_params)
    end

    # PATCH/PUT /:id/undelete
    def undelete
      reference_number = @notification.reference_number
      @notification.recover!
      redirect_to notification_path(reference_number, notification_search: @notification_search_params)
    end

  private

    def set_notification
      @notification = ::Notification.includes(responsible_person: :contact_persons).find_by(reference_number: params[:id]) ||
        ::DeletedNotification.find_by(reference_number: params[:id])
      raise ActiveRecord::RecordNotFound if @notification.nil?
    end

    def set_notification_search_params
      @notification_search_params = notification_search_params if params[:notification_search]
    end

    def notification_search_params
      params.require(:notification_search).permit(:q, :date_from, :date_to, :product_name_sort_order, :notification_complete_at_sort_order, status: [])
    end
  end
end
