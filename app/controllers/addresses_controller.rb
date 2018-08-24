class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: %i[show edit update destroy]
  before_action :create_address, only: %i[create]

  # GET /addresses
  # GET /addresses.json
  def index
    @business = Business.find(params[:business_id])
    @addresses = @business.addresses.paginate(page: params[:page], per_page: 20)
  end

  # GET /addresses/1
  # GET /addresses/1.json
  def show
    @business = @address.business
  end

  # GET /addresses/new
  def new
    @business = Business.find(params[:business_id])
    @address = @business.addresses.build
  end

  # GET /addresses/1/edit
  def edit
    @business = @address.business
  end

  # POST /addresses
  # POST /addresses.json
  def create
    respond_to do |format|
      if @address.save
        format.html { redirect_to business_addresses_url(@address.business), notice: "Address was successfully created." }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /addresses/1
  # PATCH/PUT /addresses/1.json
  def update
    authorize @address
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to @address, notice: "Address was successfully updated." }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1
  # DELETE /addresses/1.json
  def destroy
    authorize @address
    @address.destroy
    respond_to do |format|
      format.html do
        redirect_to business_addresses_url(@address.business), notice: "Address was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def create_address
    business = Business.find(params[:business_id])
    @address = business.addresses.create(address_params)
    @address.source = UserSource.new(user: current_user)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_address
    @address = Address.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def address_params
    params.require(:address).permit(:business_id, :address_type, :line_1, :line_2, :locality, :country, :postal_code)
  end
end
