class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person, only: %i[show]
  skip_before_action :create_or_join_responsible_person, only: %i[select change]
  before_action :validate_responsible_person
  before_action :responsible_persons_selection_form, only: %i[select change]

  def show; end

  def select; end

  def change
    render :select and return unless @responsible_persons_selection_form.valid?

    if @responsible_persons_selection_form.selection == "new"
      redirect_to account_path(:select_type)
    else
      set_current_responsible_person(
        current_user.responsible_persons.find(@responsible_persons_selection_form.selection),
      )
      redirect_to responsible_person_notifications_path(current_responsible_person)
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:id])
    authorize @responsible_person
  end

  def responsible_persons_selection_form
    @responsible_persons_selection_form ||=
      ResponsiblePersons::SelectionForm.new(
        responsible_persons_selection_form_params.merge(
          previous: current_responsible_person,
          available: current_user.responsible_persons,
        ),
      )
  end

  def responsible_persons_selection_form_params
    params.fetch(:responsible_persons_selection_form, {}).permit(:selection)
  end
end
