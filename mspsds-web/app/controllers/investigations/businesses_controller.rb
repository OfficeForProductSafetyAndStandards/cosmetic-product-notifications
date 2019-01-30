class Investigations::BusinessesController < ApplicationController
  include BusinessesHelper
  include Pundit
  include CountriesHelper

  before_action :set_investigation
  before_action :set_business, only: %i[link remove unlink]
  before_action :create_business, only: %i[new create]
  before_action :set_countries, only: %i[new edit create update]

  # GET /cases/1/businesses/new
  def new; end

  # POST /cases/1/businesses
  def create
    respond_to do |format|
      if @business.valid?
        @business.save
        # TODO MSPSDS-687 Create UI for setting the value to something other than the default "manufacturer"
        @investigation.add_business(@business, "manufacturer")
        format.html { redirect_to_investigation_businesses_tab "Business was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cases/1/businesses/2
  def link
    # TODO MSPSDS-687 Create UI for setting the value to something other than the default "manufacturer"
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

  def redirect_to_investigation_businesses_tab(notice)
    redirect_to investigation_path(@investigation, anchor: "businesses"), notice: notice
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
    authorize @investigation, :show?
  end
end
