class Search::DashboardController < SearchApplicationController
  def show
    redirect_to(poison_centre_notifications_path)
  end
end
