class BusinessesController < ApplicationController
  include BusinessesHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_business, only: %i[show edit update destroy]
  before_action :create_business, only: %i[new create suggested]
  before_action :update_business, only: %i[update]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = search_for_businesses(20)
  end

  # GET /businesses/1
  # GET /businesses/1.json
  def show
    return unless @business.from_companies_house?

    # TODO uncomment or delete the below line once we know whether we are keeping companies house or not
    # CompaniesHouseClient.instance.update_business_from_companies_house(@business)
  end

  # GET /businesses/new
  def new
    advanced_search
  end

  # GET /businesses/1/edit
  def edit
    @business.locations.build unless @business.locations.any?
  end

  # GET /businesses/suggested
  def suggested
    advanced_search
    render partial: "suggested"
  end

  # POST /businesses/companies_house
  def companies_house
    @business = CompaniesHouseClient.instance.create_business_from_companies_house_number params[:company_number]
    respond_to_business_creation
  end

  # POST /businesses
  # POST /businesses.json
  def create
    respond_to_business_creation
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: "Business was successfully updated." }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url, notice: "Business was successfully deleted." }
      format.json { head :no_content }
    end
  end

private

  def update_business
    @business.assign_attributes(business_params)
    defaults_on_primary_location(@business) if @business.locations.any?
  end

  def respond_to_business_creation
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: "Business was successfully created." }
        format.json { render :show, status: :created, location: @business }
      else
        @business.locations.build unless @business.locations.any?
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end
end
