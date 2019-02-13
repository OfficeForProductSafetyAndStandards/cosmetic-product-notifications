class ResponsiblePersons::NotificationsController < ApplicationController
  include ResponsiblePersons::NotificationsHelper
  before_action :set_responsible_person

  def index
    @pending_notification_files_count =
      @responsible_person.notification_files.where(user_id: current_user.id).count

    @unfinished_notifications = get_unfinished_notifications(10)

    @registered_notifications = get_registered_notifications(10)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
