class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person, only: :show
  include ResponsiblePersonConcern

  def select; end

  def change
    # TODO: assign current_responsible_user_id properly
    # TODO: security - make sure in such case user cant access wrong rp

    # TODO: spec for this line
    current_user.update!(current_responsible_person_id: current_user.responsible_persons.find(params[:id]).id)
    redirect_to responsible_person_notifications_path(current_user.current_responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
    authorize @responsible_person
  end
end
