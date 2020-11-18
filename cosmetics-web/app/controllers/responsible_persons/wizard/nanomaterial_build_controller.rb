class ResponsiblePersons::Wizard::NanomaterialBuildController < SubmitApplicationController
  include Wicked::Wizard

  steps :select_purposes,
        :confirm_restrictions,
        :confirm_usage,
        :non_standard_nanomaterial_notified,
        :when_products_containing_nanomaterial_can_be_placed_on_market,
        :notify_your_nanomaterial

  before_action :set_component
  before_action :set_nano_element

  def show
    if step == :confirm_restrictions && @nano_element.non_standard?
      return redirect_to wizard_path(:non_standard_nanomaterial_notified)
    end

    render_wizard
  end

  def update
    case step
    when :select_purposes
      render_select_purposes_step
    when :confirm_restrictions
      render_confirm_restrictions_step
    when :confirm_usage
      render_confirm_usage_step
    when :non_standard_nanomaterial_notified
      render_non_standard_nanomaterial_step
    when :when_products_containing_nanomaterial_can_be_placed_on_market
      redirect_to finish_wizard_path
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def previous_wizard_path
    case step
    when :select_purposes
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :list_nanomaterials)
    when :confirm_usage, :non_standard_nanomaterial_notified
      wizard_path(:select_purposes)
    when :when_products_containing_nanomaterial_can_be_placed_on_market, :notify_your_nanomaterial
      wizard_path(:non_standard_nanomaterial_notified)
    else
      super
    end
  end

  def finish_wizard_path
    next_nano_element = get_next_nano_element

    if next_nano_element.present?
      new_responsible_person_notification_component_nanomaterial_build_path(@component.notification.responsible_person, @component.notification, @component, next_nano_element)
    elsif @component.notification.via_zip_file?

      if @component.formulation_required?
        new_responsible_person_notification_component_formulation_path(@component.notification.responsible_person, @component.notification, @component)
      else
        # This calls an :formulation_file_uploaded event on the Notification model,
        # which sets the `state` to `draft_complete`, which is required in order to be able
        # to submit the notification. This is consistent with the logic in the
        # AdditionalInformationController.
        #
        # TODO: refactor onto the model and move away from using the `state` attribute
        # to manage required/missing information.
        @component.notification.formulation_file_uploaded!

        next_component = @component.notification.components.order(:id)
          .where(["id > ?", @component.id]).first

        if next_component
          next_nano_element = next_component.nano_material.nano_elements.order(:id).first
        end

        if next_nano_element

          new_responsible_person_notification_component_nanomaterial_build_path(@component.notification.responsible_person, @component.notification, next_component, next_nano_element)

        else

          edit_responsible_person_notification_path(@component.notification.responsible_person, @component.notification)
        end
      end
    else
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :select_category)
    end
  end

private

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_nano_element
    @nano_element = NanoElement.find(params[:nanomaterial_nano_element_id])
  end

  def nano_element_params
    params.fetch(:nano_element, {}).permit(
      :inci_name,
      :confirm_restrictions,
      :purposes,
      :confirm_usage,
      :confirm_toxicology_notified,
    )
  end

  def purpose_params
    selected_purposes = params
        .permit(nano_element: NanoElement.purposes).fetch(:nano_element, {})
        .select { |_, value| value == "1" }.keys
    { purposes: selected_purposes }
  end

  def render_select_purposes_step
    if @nano_element.update_with_context(purpose_params, step)
      render_wizard @nano_element
    else
      render step
    end
  end

  def render_confirm_restrictions_step
    confirm_restrictions = params.dig(:nano_element, :confirm_restrictions)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_restrictions
    when "yes"
      render_wizard @nano_element
    when "no"
      redirect_to wizard_path(:non_standard_nanomaterial_notified)
    else
      @nano_element.errors.add :confirm_restrictions, "Select an option"
      render step
    end
  end

  def render_confirm_usage_step
    confirm_usage = params.dig(:nano_element, :confirm_usage)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_usage
    when "yes"
      redirect_to finish_wizard_path
    when "no"
      redirect_to wizard_path(:non_standard_nanomaterial_notified)
    else
      @nano_element.errors.add :confirm_usage, "Select an option"
      render step
    end
  end

  def render_non_standard_nanomaterial_step
    confirm_toxicology_notified = params.dig(:nano_element, :confirm_toxicology_notified)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_toxicology_notified
    when "yes"
      redirect_to wizard_path(:when_products_containing_nanomaterial_can_be_placed_on_market)
    when "no"
      redirect_to wizard_path(:notify_your_nanomaterial)
    when "not sure"
      redirect_to wizard_path(:notify_your_nanomaterial)
    else
      @nano_element.errors.add :confirm_toxicology_notified, "Select an option"
      render step
    end
  end

  def get_next_nano_element
    @nano_element.nano_material.nano_elements.order(:id).each_cons(2) do |element, next_element|
      return next_element if element == @nano_element
    end
  end
end
