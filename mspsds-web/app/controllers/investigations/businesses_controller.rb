class Investigations::BusinessesController < ApplicationController
  include BusinessesHelper
  include Shared::Web::CountriesHelper
  include Wicked::Wizard
  skip_before_action :setup_wizard, only: %i[remove unlink]
  steps :type, :details

  before_action :set_investigation, only: %i[update new show remove unlink]
  before_action :set_business, only: %i[remove unlink]
  before_action :set_countries, only: %i[update show]
  before_action :set_business_location_and_contact, only: %i[update new show]
  before_action :store_business, only: %i[update]
  before_action :set_investigation_business
  before_action :business_request_params, only: %i[new]

  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def create
    if @business.save
      @investigation.add_business(@business, session[:type])
      redirect_to_investigation_businesses_tab success: "Business was successfully created."
    else
      render_wizard
    end
  end

  def show
    render_wizard
  end

  def update
    if business_valid?
      if step == :type
        assign_type
        redirect_to next_wizard_path
      else
        create
      end
    else
      render_wizard
    end
  end

  def remove; end

  # DELETE /cases/1/businesses
  def unlink
    @investigation.businesses.delete(@business)
    respond_to do |format|
      format.html do
        redirect_to_investigation_businesses_tab success: "Business was successfully removed."
      end
      format.json { head :no_content }
    end
  end

private

  def set_investigation_business
    @investigation_business = InvestigationBusiness.new(business_id: params[:id], investigation_id: @investigation.id)
  end

  def assign_type
    session[:type] = business_type_params[:type] == "other" ? business_type_params[:type_other] : business_type_params[:type]
  end

  def clear_session
    session.delete(:business)
    session.delete(:contact)
    session.delete(:location)
  end

  def business_valid?
    if step == :type
      if business_type_params[:type].nil?
        @business.errors.add(:type, "Please select a business type")
      elsif business_type_params[:type] == "other" && business_type_params[:type_other].blank?
        @business.errors.add(:type, "Please enter a business type \"Other\"")
      end
    else
      @business.valid?
    end
    @business.errors.empty?
  end

  def business_request_params
    return {} if params[:business].blank?

    business_params
  end

  def business_step_params
    business_session_params.merge(business_request_params)
  end

  def business_session_params
    session[:business] || {}
  end

  def set_business_location_and_contact
    @business = Business.new(business_step_params)
    @business.locations.build unless @business.primary_location
    @business.contacts.build unless @business.primary_contact
    defaults_on_primary_location @business
  end

  def store_business
    session[:business] = @business.attributes
    session[:contact] = @business.contacts.first.attributes
    session[:location] = @business.locations.first.attributes
  end

  def business_type_params
    params.require(:business).permit(:type, :type_other)
  end

  def redirect_to_investigation_businesses_tab(flash)
    redirect_to investigation_path(@investigation, anchor: "businesses"), flash: flash
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end
end
