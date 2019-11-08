class LandingPageController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :redirect_poison_centre_users
  before_action :set_responsible_person

  def index
    if search_domain?
      render "search_landing_page"
    else
      render "submit_landing_page"
    end
  end

private

  def redirect_poison_centre_users
    redirect_to poison_centre_notifications_path if poison_centre_or_msa_user?
  end

  def set_responsible_person
    @responsible_person = User.current.responsible_persons.first if user_signed_in?
  end
end
