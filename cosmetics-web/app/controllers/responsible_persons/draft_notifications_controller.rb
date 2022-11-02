class ResponsiblePersons::DraftNotificationsController < ResponsiblePersons::NotificationsController

  def index
    @unfinished_notifications = get_unfinished_notifications
  end

private

  def get_unfinished_notifications
    @responsible_person.notifications
      .where("state IN (?)", NotificationStateConcern::DISPLAYABLE_INCOMPLETE_STATES)
      .where("reference_number IS NOT NULL")
      .where("product_name IS NOT NULL")
      .order("updated_at DESC")
  end
end
