class ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy]
  before_action :create_product, only: %i[create]
  before_action :set_countries, only: %i[new edit]

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
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  # POST /products.json
  # This route can also be triggered when nested within an investigation
  def create
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
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

  # Use callbacks to share common setup or constraints between actions.
  def create_product
    @product = Product.new(product_params)
    @product.source = UserSource.new(user: current_user)
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def set_countries
    @countries = all_countries
  end
end
