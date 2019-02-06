class LandingPageController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_responsible_person

  def index; end

  def set_responsible_person
    return unless user_signed_in? && current_user.responsible_persons.present?

    @responsible_person = current_user.responsible_persons.first
  end
end
