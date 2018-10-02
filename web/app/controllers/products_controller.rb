class ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_product, only: %i[show edit update destroy]
  before_action :create_product, only: %i[new create suggested]
  before_action :set_countries, only: %i[create new edit]

  # GET /products
  # GET /products.json
  def index
    @products = search_for_products(20)
  end

  # GET /products/suggested
  def suggested
    @products = advanced_product_search(@product, SUGGESTED_PRODUCTS_LIMIT)
    render partial: "suggested"
  end

  # GET /products/1
  # GET /products/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @product.id.to_s
      end
    end
  end

  # GET /products/confirm_merge
  def confirm_merge
    if params[:product_ids] && params[:product_ids].length > 1
      @products = Product.find(params[:product_ids])
    else
      redirect_to products_url, notice: "Please select at least two products before merging."
    end
  end

  # POST /products/merge
  def merge
    selected_product = Product.find(params[:selected_product_id])

    other_product_ids = params[:product_ids].reject { |id| id == selected_product.id }
    other_products = Product.find(other_product_ids)

    other_products.each do |other_product|
      selected_product.merge!(other_product,
                              attributes: selected_product.attributes.keys,
                              associations: %w[investigation_products])
    end

    redirect_to products_url, notice: "Products were successfully merged."
  end

  # GET /products/new
  def new
    @products = advanced_product_search(@product, SUGGESTED_PRODUCTS_LIMIT)
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  # POST /products.json
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
end
