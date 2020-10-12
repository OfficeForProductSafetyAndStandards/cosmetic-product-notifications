class Submit::LandingPageController < SubmitApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_secondary_authentication
  skip_before_action :require_secondary_authentication
  before_action :set_responsible_person
  layout "landing_page"

  def index; end

private

  def set_responsible_person
    @responsible_person = current_user.responsible_persons.first if user_signed_in?
  end
end
