class NotificationBuildController < ApplicationController
  include Wicked::Wizard
  include Shared::Web::CountriesHelper

  steps :add_product_name, :is_imported, :add_import_country, :single_or_multi_component, :add_product_image

  before_action :set_notification
  before_action :set_countries, only: %i[show update]

  def show
    render_wizard
  end

  def update
    case step
    when :single_or_multi_component
      render_single_or_multi_component_step
    when :is_imported
      render_is_imported_step
    when :add_product_image
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
        :is_imported,
        :import_country,
        image_uploads_attributes: [file: []]
      )
  end

  def set_notification
    @notification = Notification.find_by reference_number: params[:notification_reference_number]
    authorize @notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_countries
    @countries = all_countries
  end

  def render_single_or_multi_component_step
    case params[:single_or_multi_component]
    when "single"
      @notification.components.build
      @notification.save
      redirect_to new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, @notification.components.first)
    when "multiple"
      # TODO COSBETA-10 Implement multiple components
      @notification.components.build
      render_wizard @notification
    when ""
      @notification.errors.add :components, "Must not be nil"
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
end
