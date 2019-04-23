class DashboardController < ApplicationController
  skip_before_action :authorize_user!

  def show
    if poison_centre_or_msa_user?
      redirect_to(poison_centre_notifications_path) && return
    else
      redirect_to(responsible_person_notifications_path(User.current.responsible_persons.first)) && return
    end
  end
end
