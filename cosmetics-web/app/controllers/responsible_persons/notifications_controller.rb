class ResponsiblePersons::NotificationsController < ApplicationController
  before_action :set_responsible_person

  def index
    @pending_notification_files_count =
        @responsible_person.notification_files.where(user_id: current_user.id).count

    @unfinished_notifications =
        @responsible_person.notifications.where(state: :draft_complete)

    @registered_notifications =
        @responsible_person.notifications.where(state: :notification_complete)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :index?
  end
end
