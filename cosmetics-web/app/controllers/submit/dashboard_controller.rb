class Submit::DashboardController < SubmitApplicationController
  def show
    redirect_to(responsible_person_notifications_path(current_user.responsible_persons.first))
  end
end
