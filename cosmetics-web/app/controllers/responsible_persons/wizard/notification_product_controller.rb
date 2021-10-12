class ResponsiblePersons::Wizard::NotificationProductController < SubmitApplicationController
  include Wicked::Wizard
  include CountriesHelper
  include ManualNotificationConcern

  steps :add_product_name,
        :add_internal_reference,
        :for_children_under_three,

        :contains_nanomaterials, # add info to form that later user can redefine nanomaterials, consider not showing this for edit

        :single_or_multi_component, # add info to form that later user can redefine components, consider not showing this for edit
        :add_product_image, # only for single
        :notification_product_created

  # TODO: investigate previous path helper
  before_action :set_notification

  def show
    case step
    when :add_product_image
      return render_next_step @notification if @notification.multi_component?
      render_wizard
    when :notification_product_created
      redirect_to responsible_person_notification_draft_index_path(@notification.responsible_person, @notification)
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
      if @notification.update_with_context(notification_params, step)
        render_wizard @notification
      else
        render step
      end
    when "no"
      @notification.industry_reference = nil
      render_wizard @notification
    else
      @notification.errors.add :add_internal_reference, "Select yes to add an internal reference"
      render step
    end
  end

  # Run this step only when notifications does not have any notifications
  def update_contains_nanomaterials
    return render_next_step @notification if @notification.nano_materials.count > 0

    yes_no_question(:contains_nanomaterials,
                    no_is_to_skip: false,
                    on_skip: proc { @notification.nano_materials.destroy },
                    on_next_step: proc { nanomaterial_count.times { @notification.nano_materials << NanoMaterial.create } if @notification.nano_materials.count.zero? })
  end

  def nanomaterial_count
    if params[:notification][:contains_nanomaterials] == "yes"
      params[:notification][:nanomaterial_count].to_i
    else
      0
    end
  end

  # Run this step only when notifications does not have any components
  def update_single_or_multi_component_step
    render_next_step @notification if @notification.components.count > 0

    case params.dig(:notification, :single_or_multi_component)
    when "single"
      @notification.components.create if @notification.components.empty?
      render_next_step @notification
    when "multiple"
      components_count.times { @notification.components.create }
      render_next_step @notification
    else
      @notification.errors.add :single_or_multi_component, "Select yes if the product is a multi-item kit"
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
      render_next_step @notification
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
