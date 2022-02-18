class ResponsiblePersons::Wizard::NotificationProductController < SubmitApplicationController
  include Wicked::Wizard
  include CountriesHelper
  include WizardConcern

  steps :add_product_name,
        :add_internal_reference,
        :for_children_under_three,
        :contains_nanomaterials,
        :single_or_multi_component,
        :add_product_image,
        :completed

  BACK_ROUTING = {
    add_internal_reference: :add_product_name,
    for_children_under_three: :add_internal_reference,
    contains_nanomaterials: :for_children_under_three,
    single_or_multi_component: :contains_nanomaterials,
    add_product_image: :single_or_multi_component,
  }.freeze

  # TODO: investigate previous path helper
  before_action :set_notification

  def show
    case step
    when :completed
      set_final_state_for_wizard
      render "responsible_persons/wizard/completed"
    else
      render_wizard
    end
  end

  def update
    case step
    when :add_internal_reference
      update_add_internal_reference
    when :contains_nanomaterials
      update_contains_nanomaterials
    when :single_or_multi_component
      update_single_or_multi_component_step
    when :add_product_image
      update_add_product_image_step
    else
      if @notification.update_with_context(notification_params, step)
        render_next_step @notification
      else
        rerender_current_step
      end
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

private

  def set_final_state_for_wizard
    # Make sure state wont be overrided if notification is in higher state
    return if @notification.notification_product_wizard_completed?

    @notification.set_state_on_product_wizard_completed!
  end

  def update_add_internal_reference
    case params.dig(:notification, :add_internal_reference)
    when "yes"
      model.save_routing_answer(step, "yes")
      if @notification.update_with_context(notification_params, step)
        render_wizard @notification
      else
        render step
      end
    when "no"
      model.save_routing_answer(step, "no")
      @notification.industry_reference = nil
      render_wizard @notification
    else
      @notification.errors.add :add_internal_reference, "Select yes to add an internal reference"
      render step
    end
  end

  # Run this step only when notifications does not have any notifications
  # TODO: at some point, when user changes number on nano materials,
  # state should block all other changes to force user to add nanomaterial
  def update_contains_nanomaterials
    return render_next_step @notification if @notification.nano_materials.count > 1

    answer = params.dig(:notification, :contains_nanomaterials)
    model.save_routing_answer(step, answer) if answer

    case answer
    when "yes"
      if nano_materials_count > 10
        @notification.errors.add :contains_nanomaterials, "Maximum nanomaterials count is 10. More can be added later"
        return rerender_current_step

      end
      if nano_materials_count < 1
        @notification.errors.add :contains_nanomaterials, "Please enter at least 1"
        return rerender_current_step
      end
      if @notification.nano_materials.count > 1 && nano_materials_count < @notification.nano_materials.count
        @notification.errors.add :contains_nanomaterials, "Components count cant be lower than #{@notification.components_count}"
        return rerender_current_step
      end
      required_nano_materials_count = @notification.nano_materials.present? ? nano_materials_count - 1 : nano_materials_count
      required_nano_materials_count.times do
        nano = @notification.nano_materials.create
        nano.nano_elements.create
        # TODO: quite entangled
        @notification.update_state(NotificationStateConcern::READY_FOR_NANOMATERIALS)
      end
      render_next_step @notification
    when "no"
      render_next_step @notification
    else
      @notification.errors.add :contains_nanomaterials, "Select yes if the product is a multi-item kit, no if its single item"
      rerender_current_step
    end
  end

  def nano_materials_count
    if params[:notification][:contains_nanomaterials] == "yes"
      params[:notification][:nanomaterial_count].to_i
    else
      0
    end
  end

  # Run this step only when notifications does not have any components
  def update_single_or_multi_component_step
    return render_next_step @notification if @notification.components.count > 1

    case params.dig(:notification, :single_or_multi_component)
    when "single"
      @notification.components.create if @notification.components.empty?
      render_next_step @notification
    when "multiple"
      if @notification.components_count.positive? && components_count < @notification.components_count
        @notification.errors.add :single_or_multi_component, "Items count cant be lower than #{@notification.components_count}"
        return rerender_current_step
      end
      if components_count > 10
        @notification.errors.add :single_or_multi_component, "Please select less items. More items can be added later"
        return rerender_current_step

      end
      if components_count < 2
        @notification.errors.add :single_or_multi_component, "Enter 2 or more"
        return rerender_current_step
      end
      # This happens only when there only one component
      if components_count > @notification.components.count
        # TODO: quite entangled

        # We can reset previous state, as previous state functionality
        # is to prevent messing state when nanos are added.
        @notification.reset_previous_state!
        @notification.revert_to_details_complete
      end
      required_components_count = @notification.components.present? ? components_count - 1 : components_count
      required_components_count.times { @notification.components.create }
      render_next_step @notification
    else
      @notification.errors.add :single_or_multi_component, "Select yes if the product is a multi-item kit, no if its single item"
      rerender_current_step
    end
  end

  def components_count
    params[:notification][:components_count].to_i
  end

  def update_add_product_image_step
    if params[:image_upload].present?
      params[:image_upload].each { |img| @notification.add_image(img) }
      @notification.save
      if params[:back_to_edit] == "true"
        redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
      else
        render_next_step @notification
      end
    elsif @notification.image_uploads.present?
      if params[:back_to_edit] == "true"
        redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
      else
        render_next_step @notification
      end
    else
      @notification.errors.add :image_uploads, "Select an image"
      rerender_current_step
    end
  end

  def notification_params
    params.fetch(:notification, {})
      .permit(
        :product_name,
        :industry_reference,
        :under_three_years,
        image_uploads_attributes: [file: []],
      )
  end

  def model
    @notification
  end
end
