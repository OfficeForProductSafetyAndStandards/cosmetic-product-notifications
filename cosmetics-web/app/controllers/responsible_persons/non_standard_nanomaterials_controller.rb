class ResponsiblePersons::NonStandardNanomaterialsController < ApplicationController
  before_action :set_responsible_person
  before_action :set_non_standard_nanomaterial, only: %i[edit]

  def index; end

  def new
    @non_standard_nanomaterial = NonStandardNanomaterial.create(responsible_person: @responsible_person)

    redirect_to new_responsible_person_non_standard_nanomaterial_build_path(@responsible_person, @non_standard_nanomaterial)
  end

  def edit; end

  def confirm; end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_non_standard_nanomaterial
    @non_standard_nanomaterial = NonStandardNanomaterial.find(params[:id])
    authorize @non_standard_nanomaterial, policy_class: ResponsiblePersonNonStandardNanomaterialPolicy
  end
end
