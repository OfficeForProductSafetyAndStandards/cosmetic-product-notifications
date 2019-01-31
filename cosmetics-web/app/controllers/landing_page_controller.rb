class LandingPageController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :show_dashboard

  def index; end

  def show_dashboard
    return unless user_signed_in? && current_user.responsible_persons.present?

    redirect_to responsible_person_path(current_user.responsible_persons.first)
  end
end
