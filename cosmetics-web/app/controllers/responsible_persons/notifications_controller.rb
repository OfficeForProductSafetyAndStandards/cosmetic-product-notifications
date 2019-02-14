class ResponsiblePersons::NotificationsController < ApplicationController
  before_action :set_responsible_person

  def index
    @pending_notification_files = NotificationFile.where(
      responsible_person_id: @responsible_person.id, user_id: current_user.id
    ).count
    @notifications = @responsible_person.notifications
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end
end
