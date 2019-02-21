class ResponsiblePersons::NotificationsController < ApplicationController
  before_action :set_responsible_person

  def index
    @pending_notification_files_count = @responsible_person.notification_files.where(user_id: User.current.id).count

    @unfinished_notifications = get_unfinished_notifications(10)

    @registered_notifications = get_registered_notifications(10)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def get_unfinished_notifications(page_size)
    @responsible_person.notifications.where(state: %i[notification_file_imported draft_complete])
        .paginate(page: params[:unfinished], per_page: page_size)
  end

  def get_registered_notifications(page_size)
    @responsible_person.notifications.where(state: :notification_complete)
        .paginate(page: params[:registered], per_page: page_size)
  end
end
