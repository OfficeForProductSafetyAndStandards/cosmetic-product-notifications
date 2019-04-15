class DashboardController < ApplicationController
  skip_before_action :authorize_user!

  def show
    return redirect_to responsible_person_notifications_path(User.current.responsible_persons.first) unless poison_centre_or_msa_user?

    redirect_to poison_centre_notifications_path
  end
end
