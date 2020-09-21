class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
    authorize @responsible_person
  end
end
