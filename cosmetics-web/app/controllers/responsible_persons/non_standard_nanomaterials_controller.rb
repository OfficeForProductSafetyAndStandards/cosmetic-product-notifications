class ResponsiblePersons::NonStandardNanomaterialsController < ApplicationController
  before_action :set_responsible_person

  def index; end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
