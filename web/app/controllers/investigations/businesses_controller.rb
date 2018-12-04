class Investigations::BusinessesController < ApplicationController
  include BusinessesHelper

  before_action :set_investigation, only: %i[new create suggested link remove unlink companies_house]
  before_action :set_business, only: %i[link remove unlink]
  before_action :create_business, only: %i[new create suggested]

  # GET /investigations/1/businesses/new
  def new
    advanced_search(@investigation.businesses.map(&:id))
  end

  # GET /investigations/1/businesses/suggested
  def suggested
    excluded_business_ids = params[:excluded_businesses].split(",").map(&:to_i)
    advanced_search(excluded_business_ids)
    render partial: "businesses/suggested"
  end

  # POST /businesses/companies_house
  def companies_house
    @business = CompaniesHouseClient.instance.create_business_from_companies_house_number params[:company_number]
    @investigation.businesses << @business
    redirect_to_investigation_businesses_tab "Business was successfully added."
  end

  # POST /investigations/1/businesses
  def create
    respond_to do |format|
      if @business.valid?
        @investigation.businesses << @business
        format.html { redirect_to_investigation_businesses_tab "Business was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        advanced_search(@investigation.businesses.map(&:id))
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /investigations/1/businesses/2
  def link
    @investigation.businesses << @business
    redirect_to_investigation_businesses_tab "Business was successfully linked."
  end

  def remove; end

  # DELETE /investigations/1/businesses
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
  end
end
