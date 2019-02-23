class Investigations::BusinessesController < ApplicationController
  include ActiveModel::Validations
  include BusinessesHelper
  include Pundit
  include Shared::Web::CountriesHelper
  include Wicked::Wizard
  skip_before_action :setup_wizard, only: %i[remove unlink]
  steps :type, :details

  validates :name, presence: true
  before_action :set_investigation, only: %i[update new show remove unlink]
  before_action :set_business, only: %i[remove unlink]
  before_action :set_countries, only: %i[show]
  before_action :set_business_locally, only: %i[update new show]
  before_action :store_business, only: %i[update]
  before_action :set_investigation_business

  def new
    redirect_to wizard_path(steps.first)
  end

  def show
    render_wizard
  end

  def update
    if step == :type
      if business_type_params[:relationship].nil?
        @business.errors.add(:base, "Please select a business type")
        return render_wizard
      elsif business_type_params[:relationship] == "Other" && business_type_params[:relationship_other].blank?
        @business.errors.add(:base, "Please enter a business type \"Other\"")
        return render_wizard
      end
      session[:relationship] = business_type_params[:relationship] == "Other" ? business_type_params[:relationship_other] : business_type_params[:relationship]
      redirect_to next_wizard_path
    else
      @business = Business.new(business_params)
      if @business.valid?
        @business.save
        @investigation.add_business(@business, session[:relationship])
        redirect_to_investigation_businesses_tab "Business was successfully created."
      end
    end
  end

  def set_investigation_business
    @investigation_business = InvestigationBusiness.new(business_id: params[:id], investigation_id: @investigation.id)
  end

  def remove; end

  # DELETE /cases/1/businesses
  def unlink
    @investigation.businesses.delete(@business)
    respond_to do |format|
      format.html do
        redirect_to_investigation_businesses_tab "Business was successfully removed."
      end
      format.json { head :no_content }
    end
  end

private

  def set_business_locally
    @business = Business.new
    @business.locations.build
    @business.contacts.build
  end

  def store_business
    session[:business] = @business.attributes
  end

  def business_type_params
    params.require(:business).permit(:relationship, :relationship_other)
  end

  def redirect_to_investigation_businesses_tab(notice)
    redirect_to investigation_path(@investigation, anchor: "businesses"), notice: notice
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
    authorize @investigation, :show?
  end
end
