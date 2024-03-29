class Search::LandingPageController < SearchApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_secondary_authentication
  skip_before_action :require_secondary_authentication

  before_action :redirect_to_notifications

  layout "landing_page"

  def index; end

private

  def redirect_to_notifications
    redirect_to poison_centre_notifications_search_path if user_signed_in?
  end
end
