class Submit::LandingPageController < SubmitApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_secondary_authentication
  skip_before_action :require_secondary_authentication

  before_action :redirect_poison_centre_users
  before_action :set_responsible_person

  def index; end

private

  def redirect_poison_centre_users
    redirect_to poison_centre_notifications_path if poison_centre_or_msa_user?
  end

  def set_responsible_person
    @responsible_person = current_user.responsible_persons.first if user_signed_in?
  end
end
