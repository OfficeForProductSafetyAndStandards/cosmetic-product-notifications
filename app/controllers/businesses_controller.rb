class BusinessesController < ApplicationController
  include BusinessesHelper
  before_action :authenticate_user!
  before_action :set_business, only: %i[show edit update destroy]
  before_action :create_business, only: %i[create]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = Business.paginate(page: params[:page], per_page: 20)
  end

  # GET /businesses/1
  # GET /businesses/1.json
  def show; end

  # GET /businesses/new
  def new
    @business = Business.new
  end

  # GET /businesses/1/edit
  def edit; end

  # GET /businesses/companies_house
  def companies_house
    @businesses = companies_house_businesses params[:q]
    render partial: "companies_house"
  end

  # POST /businesses
  # POST /businesses.json
  def create
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: "Business was successfully created." }
        format.json { render :show, status: :created, location: @business }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    respond_to do |format|
      if @business.update(business_params)
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
      format.html { redirect_to businesses_url, notice: "Business was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def create_business
    @business = Business.new(business_params)
    @business.source = UserSource.new(user: current_user)
  end

  def set_business
    @business = Business.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def business_params
    params.require(:business).permit(
      :company_number,
      :company_name,
      :company_type_code,
      :registered_office_address_line_1, :registered_office_address_line_2, :registered_office_address_locality,
      :registered_office_address_country, :registered_office_address_postal_code,
      :nature_of_business_id,
      :additional_information
    )
  end
end
