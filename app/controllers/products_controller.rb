class ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_investigation, only: %i[suggested_for_investigation new create new_for_investigation]
  before_action :create_product, only: %i[new create]
  before_action :set_countries, only: %i[new edit new_for_investigation]

  # GET /products
  # GET /products.json
  def index
    @products = search_for_products(20)
  end

  # GET /products/suggested
  def suggested
    @products = advanced_product_search(4)
    render partial: "suggested"
  end

  # GET /investigations/1/products/suggested
  def suggested_for_investigation
    @products = advanced_product_search(20)
                .reject { |product| @investigation.product_ids.include?(product.id) }[0...4]
    render partial: "suggested"
  end

  # GET /products/1
  # GET /products/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @product.id
      end
    end
  end

  # GET /products/new
  def new; end

  # GET /investigations/1/products/new
  def new_for_investigation
    @product = Product.new
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  # POST /products.json
  # This route can also be triggered when nested within an investigation
  def create
    respond_to do |format|
      if save_product
        format.html { redirect_to (@investigation.presence || @product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_investigation
    @investigation = Investigation.find_by(id: params[:investigation_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def create_product
    if params[:product]
      @product = Product.new(product_params)
      @product.source = UserSource.new(user: current_user)
    else
      @product = Product.new
    end
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def set_countries
    @countries = all_countries
  end

  def save_product
    if @investigation.present?
      @investigation.products << @product
    else
      @product.save
    end
  end
end
