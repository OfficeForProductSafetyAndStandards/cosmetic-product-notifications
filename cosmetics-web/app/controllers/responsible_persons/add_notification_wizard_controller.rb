class ResponsiblePersons::AddNotificationWizardController < ApplicationController
  include Wicked::Wizard

  before_action :set_responsible_person, only: %i[update show]

  steps :have_products_been_notified_in_eu, :will_products_be_notified_in_eu,
      :do_you_have_files_from_eu_notification, :was_product_on_sale_before_eu_exit,
      :register_on_eu_system

  def show
    render_wizard
  end

  def update
    map = {
        have_products_been_notified_in_eu: {
            "yes" => wizard_path(:do_you_have_files_from_eu_notification),
            "no" => wizard_path(:will_products_be_notified_in_eu)
        },
        will_products_be_notified_in_eu: {
            "yes" => wizard_path(:register_on_eu_system),
            "no" => wizard_path(:was_product_on_sale_before_eu_exit)
        },
        do_you_have_files_from_eu_notification: {
            "yes" => bulk_upload_path,
            "no" => manual_journey_path(notified_before_eu_exit: false)
        },
        was_product_on_sale_before_eu_exit: {
            "yes" => manual_journey_path(notified_before_eu_exit: true),
            "no" => manual_journey_path(notified_before_eu_exit: false)
        }
    }

    redirect_to map[step][params[:answer]]
  end

  def new
    redirect_to wizard_path(steps.first)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def manual_journey_path(notified_before_eu_exit)
    new_responsible_person_notification_path(@responsible_person, notified_before_eu_exit)
  end

  def bulk_upload_path
    new_responsible_person_notification_file_path(@responsible_person)
  end
end
