module ResponsiblePersons::NotificationsHelper
  def get_unfinished_notifications(page_size)
    @responsible_person.notifications.where(state: :draft_complete)
        .paginate(:page => params[:unfinished], :per_page => page_size)
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications.where(state: :notification_complete)
        .paginate(:page => params[:registered], :per_page => page_size)
  end
end
