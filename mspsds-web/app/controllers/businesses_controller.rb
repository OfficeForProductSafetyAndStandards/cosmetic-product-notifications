class BusinessesController < ApplicationController
  include BusinessesHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_business, only: %i[show edit update destroy]
  before_action :create_business, only: %i[new create]
  before_action :update_business, only: %i[update]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = search_for_businesses(20)
  end

  # GET /businesses/1
  # GET /businesses/1.json
  def show; end

  # GET /businesses/new
  def new
  end

  # GET /businesses/1/edit
  def edit
    @business.locations.build unless @business.locations.any?
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
