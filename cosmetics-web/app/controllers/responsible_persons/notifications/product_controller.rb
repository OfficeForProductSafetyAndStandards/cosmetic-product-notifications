class ResponsiblePersons::Notifications::ProductController < SubmitApplicationController
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

  before_action :set_notification
  before_action :contains_nanomaterials_form, if: -> { step == :contains_nanomaterials }
  before_action :single_or_multi_component_form, if: -> { step == :single_or_multi_component }

  def show
    case step
    when :completed
      @notification.set_state_on_product_wizard_completed!
      render "responsible_persons/notifications/task_completed"
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

  def update_add_internal_reference
    case params.dig(:notification, :add_internal_reference)
    when "yes"
      model.save_routing_answer(step, "yes")
      if @notification.update_with_context(notification_params, step)
        render_next_step @notification
      else
        rerender_current_step
      end
    when "no"
      model.save_routing_answer(step, "no")
      @notification.industry_reference = nil
      render_next_step @notification
    else
      @notification.errors.add :add_internal_reference, "Select yes to add an internal reference"
      rerender_current_step
    end
  end

  # Run this step only when notification doesn't already have nanomaterials
  def update_contains_nanomaterials
    return render_next_step @notification if @notification.nano_materials.any?

    form = contains_nanomaterials_form
    return rerender_current_step unless form.valid?

    model.save_routing_answer(step, form.contains_nanomaterials)
    @notification.make_ready_for_nanomaterials!(form.nanomaterials_count.to_i)
    render_next_step @notification
  end

  # Run this step only when notifications does not have multiple components
  def update_single_or_multi_component_step
    return render_next_step @notification if @notification.multi_component?

    form = single_or_multi_component_form
    return rerender_current_step unless form.valid?

    @notification.make_single_ready_for_components!(form.components_count.to_i)
    render_next_step @notification
  end

  def update_add_product_image_step
    if params[:image_upload].present?
      params[:image_upload].each { |img| @notification.add_image(img) }
      @notification.save
      if params[:back_to_edit] == "true"
        redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
      elsif params[:after_save] == "upload_another"
        rerender_current_step
      else
        render_next_step @notification
      end
    elsif @notification.image_uploads.present?
      if params[:back_to_edit] == "true"
        redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
      elsif params[:after_save] == "upload_another"
        rerender_current_step
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

  def contains_nanomaterials_params
    params.fetch(:contains_nanomaterials_form, {})
          .permit(:contains_nanomaterials, :nanomaterials_count)
  end

  def single_or_multi_component_params
    params.fetch(:single_or_multi_component_form, {})
          .permit(:single_or_multi_component, :components_count)
  end

  def contains_nanomaterials_form
    @contains_nanomaterials_form ||=
      ResponsiblePersons::Notifications::Product::ContainsNanomaterialsForm.new(contains_nanomaterials_params)
  end

  def single_or_multi_component_form
    @single_or_multi_component_form ||=
      ResponsiblePersons::Notifications::Product::SingleOrMultiComponentForm.new(single_or_multi_component_params)
  end

  def model
    @notification
  end
end
