class ResponsiblePersons::NotificationsController < ApplicationController
  before_action :set_responsible_person

  def index
    @pending_notification_files = NotificationFile.where(
      ["responsible_person_id = ? and user_id = ?", @responsible_person.id, current_user.id]
    ).count
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end
end
