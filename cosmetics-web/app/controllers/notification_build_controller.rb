class NotificationBuildController < ApplicationController
  include Wicked::Wizard
  include Shared::Web::CountriesHelper

  steps :add_product_name,
        :add_internal_reference,
        :is_imported,
        :add_import_country,
        :single_or_multi_component,
        :is_mixed,
        :is_hair_dye,
        :add_new_component,
        :add_product_image

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
    when :is_imported
      render_is_imported_step
    when :add_new_component
      render_add_new_component_step
    when :add_product_image
      render_add_product_image_step
    when :add_internal_reference
      render_add_internal_reference
    else
      @notification.update(notification_params)

      if step == :add_import_country && @notification.import_country.blank?
        @notification.errors.add :import_country, "Must not be blank"
        render step
      else
        render_wizard @notification
      end
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def finish_wizard_path
    edit_responsible_person_notification_path(@notification.responsible_person, @notification)
  end

private

  def notification_params
    params.require(:notification)
      .permit(
        :product_name,
        :industry_reference,
        :is_imported,
        :import_country,
        image_uploads_attributes: [file: []]
      )
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_countries
    @countries = all_countries
  end

  def component_params
    return {} if params[:notification].blank?

    params.require(:notification).permit(:components_are_mixed)
  end

  def render_single_or_multi_component_step
    case params[:single_or_multi_component]
    when "single"
      @notification.components.destroy_all if @notification.is_multicomponent?
      single_component = @notification.components.empty? ? @notification.components.create : @notification.components.first
      redirect_to new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, single_component)
    when "multiple"
      unless @notification.is_multicomponent?
        @notification.components.destroy_all
        @notification.components.build
        @notification.components.build
        @notification.save
      end
      render_wizard @notification
    else
      @notification.errors.add :components, "Must not be nil"
      render step
    end
  end

  def render_is_mixed_step
    @notification.update(component_params)

    if @notification.components_are_mixed.nil?
      @notification.errors.add :components_are_mixed, "Must select an option"
      return render step
    end

    if @notification.components_are_mixed
      render_wizard @notification
    else
      redirect_to responsible_person_notification_build_path(@notification.responsible_person, @notification, :add_new_component)
    end
  end

  def render_is_hair_dye_step
    case params[:notification][:is_hair_dye]
    when "true"
      render_wizard @notification
    when "false"
      render_wizard @notification
    else
      @notification.errors.add :is_hair_dye, "Must select an option"
      render step
    end
  end

  def render_is_imported_step
    case params[:is_imported]
    when "true"
      render_wizard @notification
    when "false"
      @notification.import_country = nil
      @notification.add_import_country
      jump_to :single_or_multi_component
      render_wizard @notification
    when ""
      @notification.errors.add :import_country, "Must not be nil"
      render step
    end
  end

  def render_add_new_component_step
    if params.key?(:remove_component)
      remove_component_id = params[:remove_component].to_i
      componet_to_remove = @notification.components.select { |component| component.id == remove_component_id }
      @notification.components.delete(componet_to_remove)
      @notification.components.create if @notification.components.length < 2
      render step
    elsif params.key?(:add_component) && params[:add_component]
      invalid_multicomponents = @notification.get_invalid_multicomponents
      new_component = invalid_multicomponents.empty? ? @notification.components.create : invalid_multicomponents.first
      redirect_to new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, new_component)
    elsif @notification.get_valid_multicomponents.length > 1
      render_wizard @notification
    else
      render step
    end
  end

  def render_add_product_image_step
    if params[:image_upload].present?
      params[:image_upload].each do |image|
        image_upload = @notification.image_uploads.build
        image_upload.file.attach(image)
        image_upload.filename = image.original_filename
      end
      @notification.add_product_image
      render_wizard @notification
    else
      @notification.errors.add :image_uploads, "You must upload at least one product image"
      render step
    end
  end

  def render_add_internal_reference
    if params[:notification].present? && params[:notification][:add_internal_reference] == 'true'
      if params[:notification][:industry_reference].blank?
        @notification.errors.add :industry_reference, "Please enter an internal reference"
        return render step
      end
      @notification.update industry_reference: params[:notification][:industry_reference]
    elsif params[:notification].blank? || params[:notification][:add_internal_reference].blank?
      @notification.errors.add :add_internal_reference, "Please select an option"
      return render step
    end
    render_wizard @notification
  end
end
