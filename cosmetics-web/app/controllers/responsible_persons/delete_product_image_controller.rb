class ResponsiblePersons::DeleteProductImageController < SubmitApplicationController
  before_action :set_notification

  def destroy
    @notification.image_uploads.find(params[:image_id]).destroy
    redirect_back fallback_location: responsible_person_notification_draft_path(@notification.responsible_person, @notification)
  end

  private

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
