class ResponsiblePersonsController < SubmitApplicationController
  before_action :set_responsible_person, only: %i[show edit update]
  skip_before_action :create_or_join_responsible_person, only: %i[select change]
  before_action :validate_responsible_person
  before_action :responsible_persons_selection_form, only: %i[select change]

  def show; end

  def select; end

  def change
    if @responsible_persons_selection_form.invalid?
      render :select
    elsif @responsible_persons_selection_form.add_new?
      redirect_to account_path(:enter_details)
    else
      message = current_responsible_person ? "Responsible Person was changed" : nil
      set_current_responsible_person(
        current_user.responsible_persons.find(@responsible_persons_selection_form.selection),
      )
      redirect_to responsible_person_path(current_responsible_person), confirmation: message
    end
  end

  def edit; end

  def update
    result = UpdateResponsiblePersonDetails.call(responsible_person: @responsible_person,
                                                 user: current_user,
                                                 details: update_params.to_h)
    if result.success?
      confirmation = "Responsible Person details changed successfully" if result.changed
      redirect_to(responsible_person_path(@responsible_person), confirmation:)
    else
      render :edit
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

  def update_params
    params.require(:responsible_person).permit(
      :account_type,
      :address_line_1,
      :address_line_2,
      :city,
      :county,
      :postal_code,
    )
  end

  def responsible_persons_selection_form_params
    params.fetch(:responsible_persons_selection_form, {}).permit(:selection)
  end
end
