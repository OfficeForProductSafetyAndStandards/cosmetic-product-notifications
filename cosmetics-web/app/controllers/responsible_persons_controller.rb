class ResponsiblePersonsController < ApplicationController
  before_action :set_responsible_person

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
  end
end
