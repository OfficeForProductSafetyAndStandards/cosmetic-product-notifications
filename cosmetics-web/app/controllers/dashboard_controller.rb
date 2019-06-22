class DashboardController < ApplicationController
  def show
    if poison_centre_or_msa_user?
      redirect_to(poison_centre_notifications_path)
    else
      redirect_to(responsible_person_notifications_path(User.current.responsible_persons.first))
    end
  end
end
