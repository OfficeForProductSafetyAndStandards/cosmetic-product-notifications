class NonStandardNanomaterialBuildController < ApplicationController
  include Wicked::Wizard

  steps :add_iupac_name

  before_action :set_responsible_person
  before_action :set_non_standard_nanomaterial, only: %i[show update]

  def show
    render_wizard
  end

  def update
    # Apply this since render_wizard(@component, context: :context) doesn't work as expected
    if @non_standard_nanomaterial.update_with_context(non_standard_nanomaterial_params, step)
      render_wizard @non_standard_nanomaterial
    else
      render step
    end
  end

  def finish_wizard_path
    edit_responsible_person_non_standard_nanomaterial_path(@responsible_person, @non_standard_nanomaterial)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    # authorize @responsible_person, :show?
  end

  def set_non_standard_nanomaterial
    @non_standard_nanomaterial = NonStandardNanomaterial.find(params[:non_standard_nanomaterial_id])
    # authorize @non_standard_nanomaterial.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def non_standard_nanomaterial_params
    params.fetch(:non_standard_nanomaterial, {})
        .permit(
          :iupac_name
        )
  end
end
