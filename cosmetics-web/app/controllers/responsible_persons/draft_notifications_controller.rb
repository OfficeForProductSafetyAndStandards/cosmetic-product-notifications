class ResponsiblePersons::DraftNotificationsController < ResponsiblePersons::NotificationsController
  def index
    @unfinished_notifications = get_unfinished_notifications(20)
  end

private

  def get_unfinished_notifications(page_size)
    @responsible_person.notifications
      .where("state IN (?)", NotificationStateConcern::DISPLAYABLE_INCOMPLETE_STATES)
      .where("reference_number IS NOT NULL")
      .where("product_name IS NOT NULL")
      .order("updated_at DESC")
      .page(params[:page]).per(page_size)
  end
end
