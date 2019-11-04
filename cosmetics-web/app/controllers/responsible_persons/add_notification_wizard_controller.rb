class ResponsiblePersons::AddNotificationWizardController < ApplicationController
  include Wicked::Wizard

  before_action :set_responsible_person, only: %i[update show]

  steps :have_products_been_notified_in_eu,
        :will_products_be_notified_in_eu,
        :do_you_have_files_from_eu_notification,
        :was_product_on_sale_before_eu_exit,
        :register_on_eu_system

  def show
    render_wizard
  end

  def update
    answer = params[:answer]
    if answer != "yes" && answer != "no"
      @error_text = "Select an answer"
      return render step
    end

    case step
    when :have_products_been_notified_in_eu
      if answer == "yes"
        redirect_to wizard_path(:do_you_have_files_from_eu_notification)
      else
        redirect_to wizard_path(:will_products_be_notified_in_eu)
      end
    when :will_products_be_notified_in_eu
      if answer == "yes"
        redirect_to wizard_path(:register_on_eu_system)
      else
        redirect_to manual_journey_path(notified_before_eu_exit: false)
      end
    when :do_you_have_files_from_eu_notification
      if answer == "yes"
        redirect_to bulk_upload_path
      else
        redirect_to wizard_path(:was_product_on_sale_before_eu_exit)
      end
    when :was_product_on_sale_before_eu_exit
      if answer == "yes"
        redirect_to manual_journey_path(notified_before_eu_exit: true)
      else
        redirect_to manual_journey_path(notified_before_eu_exit: false)
      end
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def manual_journey_path(notified_before_eu_exit)
    new_responsible_person_notification_path(@responsible_person, notified_before_eu_exit)
  end

  def bulk_upload_path
    new_responsible_person_notification_file_path(@responsible_person)
  end
end
