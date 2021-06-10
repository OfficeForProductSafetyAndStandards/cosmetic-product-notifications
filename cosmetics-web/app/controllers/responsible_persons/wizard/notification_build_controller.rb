class ResponsiblePersons::Wizard::NotificationBuildController < SubmitApplicationController
  include Wicked::Wizard
  include CountriesHelper
  include ManualNotificationConcern

  steps :add_product_name,
        :add_internal_reference,
        :for_children_under_three,
        :single_or_multi_component,
        :add_product_image,
        :is_mixed, # only for multicomponent - at least code says so
        :is_hair_dye, # only for multicomponent - at least code says so
        :is_ph_between_3_and_10, # only for multicomponent - at least code says so
        :ph_range, # only for multicomponent - at least code says so
        :add_new_component # only for multicomponent

  before_action :set_notification
  before_action :set_countries, only: %i[show update]

  def show
    render_wizard
  end

  def update
    case step
    when :single_or_multi_component
      render_single_or_multi_component_step
    when :is_mixed
      render_is_mixed_step
    when :is_hair_dye
      render_is_hair_dye_step
    when :is_ph_between_3_and_10
      render_is_ph_between_3_and_10_step
    when :add_new_component
      render_add_new_component_step
    when :add_product_image
      render_add_product_image_step
    when :add_internal_reference
      render_add_internal_reference
    else
      if @notification.update_with_context(notification_params, step)
        render_wizard @notification
      else
        render step
      end
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def finish_wizard_path
    edit_responsible_person_notification_path(@notification.responsible_person, @notification)
  end

  def previous_wizard_path
    previous_step = get_previous_step

    if step == :add_product_name
      last_step = if request.referer&.end_with? "do_you_have_files_from_eu_notification"
                    :do_you_have_files_from_eu_notification
                  else
                    :will_products_be_notified_in_eu
                  end
      responsible_person_add_notification_path(@notification.responsible_person, last_step)
    elsif step == :add_new_component && @notification.state == "draft_complete"
      last_component = @notification.components.complete.last
      last_step = last_component.ph_range_not_required? ? :select_ph_range : :ph
      responsible_person_notification_component_trigger_question_path(@notification.responsible_person, @notification, last_component, last_step)
    elsif previous_step.present?
      responsible_person_notification_build_path(@notification.responsible_person, @notification, previous_step)
    else
      super
    end
  end

private

  def notification_params
    params.fetch(:notification, {})
      .permit(
        :product_name,
        :industry_reference,
        :under_three_years,
        :components_are_mixed,
        :ph_min_value,
        :ph_max_value,
        image_uploads_attributes: [file: []],
      )
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_countries
    @countries = all_countries
  end

  def render_single_or_multi_component_step
    case params.dig(:notification, :single_or_multi_component)
    when "single"
      @notification.components.destroy_all if @notification.is_multicomponent?
      @notification.components.create if @notification.components.empty?
      render_wizard @notification
    when "multiple"
      unless @notification.is_multicomponent?
        @notification.components.destroy_all
        @notification.components.build
        @notification.components.build
        @notification.save
      end
      render_wizard @notification
    else
      @notification.errors.add :single_or_multi_component, "Select yes if the product is a multi-item kit"
      render step
    end
  end

  def render_is_mixed_step
    if @notification.update_with_context(notification_params, step)
      unless @notification.components_are_mixed
        clear_ph_range
        jump_to(next_step(:ph_range))
      end
      render_wizard @notification
    else
      render step
    end
  end

  def render_is_hair_dye_step
    yes_no_question(:is_hair_dye, no_is_to_skip: false)
  end

  def render_is_ph_between_3_and_10_step
    yes_no_question(:is_ph_between_3_and_10, before_skip: method(:clear_ph_range))
  end

  def render_add_new_component_step
    if params.key?(:remove_component)
      remove_component_id = params[:remove_component].to_i
      componet_to_remove = @notification.components.select { |component| component.id == remove_component_id }
      @notification.components.destroy(componet_to_remove)
      @notification.components.create if @notification.components.length < 2
      render step
    elsif params.key?(:add_component) && params[:add_component]
      invalid_multicomponents = @notification.get_invalid_multicomponents
      new_component = invalid_multicomponents.empty? ? @notification.components.create : invalid_multicomponents.first
      redirect_to new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, new_component)
    elsif @notification.get_valid_multicomponents.length > 1
      @notification.complete_draft!
      render_wizard @notification
    else
      render step
    end
  end

  def render_add_product_image_step
    if params[:image_upload].present?
      params[:image_upload].each { |img| @notification.add_image(img) }
      @notification.save
      if @notification.is_multicomponent?
        render_wizard @notification
      else
        redirect_to new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, @notification.components.first)
      end
    else
      @notification.errors.add :image_uploads, "Select an image"
      render step
    end
  end

  def render_add_internal_reference
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

  def clear_ph_range
    @notification.update(ph_min_value: nil, ph_max_value: nil)
  end

  def get_previous_step
    case step
    when :for_children_under_three
      :add_internal_reference
    when :is_mixed
      :add_product_image
    when :ph_range
      :is_hair_dye
    when :add_new_component
      if @notification.components_are_mixed
        if @notification.ph_min_value.present? && @notification.ph_max_value.present?
          :ph_range
        else
          :is_hair_dye
        end
      else
        :is_mixed
      end
    when :add_product_image
      :single_or_multi_component
    end
  end

  def model
    @notification
  end
end
