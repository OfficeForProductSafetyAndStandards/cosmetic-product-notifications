class Investigations::BusinessesController < ApplicationController
  include BusinessesHelper
  include Pundit
  include Shared::Web::CountriesHelper

  before_action :set_investigation
  before_action :set_business, only: %i[remove unlink]
  before_action :create_business, only: %i[new create]
  before_action :set_countries, only: %i[new create]

  # GET /cases/1/businesses/new
  def new
    session[:relationship] = if params[:relationship] == "Other"
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
