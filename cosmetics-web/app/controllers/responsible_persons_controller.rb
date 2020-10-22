class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person, only: %i[show]
  include ResponsiblePersonConcern

  def show; end

  def select; end

  def change
    # TODO: assign current_responsible_user_id properly
    # TODO: security - make sure in such case user cant access wrong rp

    # TODO: spec for this line
    set_current_responsible_person(current_user.responsible_persons.find(params[:id]))
    redirect_to responsible_person_notifications_path(current_responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
    authorize @responsible_person
  end
end
