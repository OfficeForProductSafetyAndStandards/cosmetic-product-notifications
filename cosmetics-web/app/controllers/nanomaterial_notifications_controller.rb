class NanomaterialNotificationsController < ApplicationController

  before_action :set_responsible_person

  def index
  end

  def new

  end

  private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

end
