class ResponsiblePersons::NonStandardNanomaterialsController < ApplicationController
  before_action :set_responsible_person

  def index; end

  def new
    @non_standard_nanomaterial = NonStandardNanomaterial.create(responsible_person: @responsible_person)

    redirect_to responsible_person_non_standard_nanomaterial_build_path(@responsible_person, @non_standard_nanomaterial, :add_iupac_name)
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end
end
