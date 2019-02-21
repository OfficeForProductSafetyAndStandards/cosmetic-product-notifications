class LandingPageController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_responsible_person

  def index; end

  def set_responsible_person
    return if User.current&.responsible_persons.blank?

    @responsible_person = User.current.responsible_persons.first
  end
end
