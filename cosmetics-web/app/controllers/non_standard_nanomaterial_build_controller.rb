class NonStandardNanomaterialBuildController < ApplicationController
  include Wicked::Wizard

  steps :add_iupac_name

  before_action :set_responsible_person
  before_action :set_nanomaterial

  def show
    render_wizard
  end

  def update
    # Apply this since render_wizard(@component, context: :context) doesn't work as expected
    if @nanomaterial.update_with_context(nanomaterial_params, step)
      render_wizard @nanomaterial
    else
      render step
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def finish_wizard_path
    edit_responsible_person_non_standard_nanomaterial_path(@responsible_person, @nanomaterial)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def set_nanomaterial
    @nanomaterial = NonStandardNanomaterial.find(params[:non_standard_nanomaterial_id])
    authorize @nanomaterial, :update?, policy_class: ResponsiblePersonNonStandardNanomaterialPolicy
  end

  def nanomaterial_params
    params.fetch(:non_standard_nanomaterial, {})
        .permit(
          :iupac_name,
        )
  end
end
