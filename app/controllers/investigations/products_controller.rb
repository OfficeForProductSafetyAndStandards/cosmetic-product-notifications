class Investigations::ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  before_action :authenticate_user!
  before_action :set_investigation, only: %i[index search new create suggested add destroy]
  before_action :set_product, only: %i[destroy]
  before_action :create_product, only: %i[new create]
  before_action :set_countries, only: %i[search new]

  # GET /investigations/1/products
  def index; end

  # GET /investigations/1/products/search
  def search
    @product = Product.new
  end

  # GET /investigations/1/products/new
  def new; end

  # POST /investigations/1/products/add
  def add
    @investigation.products << Product.find(params[:product_id])
    redirect_to @investigation, notice: "Product was successfully added."
  end

  # GET /investigations/1/products/suggested
  def suggested
    excluded_product_ids = params[:excluded_products].split(",")
    @products = advanced_product_search(20)
                .reject { |product| excluded_product_ids.include?(product.id) }[0...4]
    render partial: "products/suggested"
  end

  # POST /investigations/1/products
  def create
    respond_to do |format|
      if @investigation.products << @product
        format.html { redirect_to @investigation, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investigations/1/products
  def destroy
    @investigation.products.delete(@product)
    respond_to do |format|
      format.html do
        redirect_to investigation_products_path(@investigation),
                    notice: "Product was successfully removed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_countries
    @countries = all_countries
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def create_product
    if params[:product]
      @product = Product.new(product_params)
      @product.source = UserSource.new(user: current_user)
    else
      @product = Product.new
    end
  end
end
