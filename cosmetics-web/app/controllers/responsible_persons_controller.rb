class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person, only: :show

  def change; end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
    authorize @responsible_person
  end
end
