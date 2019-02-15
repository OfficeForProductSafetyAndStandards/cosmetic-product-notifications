class Investigations::BusinessesController < ApplicationController
  include ActiveModel::Validations
  include BusinessesHelper
  include Pundit
  include Shared::Web::CountriesHelper
  include Wicked::Wizard

  steps :type, :details

  validates :name, presence: true
  before_action :set_investigation
  before_action :set_business, only: %i[update show link remove unlink]
  before_action :store_business, only: %i[update]
  before_action :set_investigation_business
  before_action :create_business, only: %i[new create]
  before_action :set_countries, only: %i[new create]

  # GET /cases/1/businesses/new
  def show
    render_wizard
  end

  def update
    p "----params---"
    p params
    p business_type_params[:relationship]
    if step == :type
      @business.errors.add(:base, "No relationship") if business_type_params[:relationship].nil?
      @business.errors.add(:base, "No relationship other") if business_type_params[:relationship] == "Other" && business_type_params[:relationship_other].blank?
      return render_wizard if @business.errors.any?
      p business_type_params[:relationship]
      session[:relationship] = business_type_params[:relationship] == "Other" ? business_type_params[:relationship_other] : business_type_params[:relationship]
      p session[:relationship]
    else
      # @business = Business.new(business_params)
      if @business.valid?
        @business.save
        @investigation.add_business(@business, session[:relationship])
        return redirect_to_investigation_businesses_tab "Business was successfully created."
      end
    end
    redirect_to next_wizard_path
  end

  def new
    redirect_to wizard_path(steps.first)
    relationship = if params[:relationship] == "Other"
                     params[:relationship_other]
                   else
                     params[:relationship]
                   end
  end

  # POST /cases/1/businesses
  def create
    respond_to do |format|
      if @business.valid?
        @business.save
        p session[:relationship]
        relationship = session[:relationship]
        @investigation.add_business(@business, relationship)
        format.html { redirect_to_investigation_businesses_tab "Business was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_investigation_business
    @investigation_business = InvestigationBusiness.new(business_id: params[:id], investigation_id: @investigation.id)
  end

  def link
    # TODO MSPSDS-938 Create UI for setting the value to something other than the default "manufacturer"
    # (also examine if this method is still relevant and needed)
    @investigation.add_business(@business, "manufacturer")
    redirect_to_investigation_businesses_tab "Business was successfully linked."
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

  def set_business
    @business = Business.new
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
