class ProductsController < ApplicationController
  include Shared::Web::CountriesHelper
  include ProductsHelper
  include UrlHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_product, only: %i[show edit update]
  before_action :set_countries, only: %i[update edit]
  before_action :build_breadcrumbs, only: %i[show]

  # GET /products
  # GET /products.json
  def index
    @products = search_for_products(20)
  end

  # GET /products/1
  # GET /products/1.json
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /products/1/edit
  def edit; end

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
      format.html { redirect_to products_url, notice: "Product was successfully deleted." }
      format.json { head :no_content }
    end
  end

private

  def build_breadcrumbs
    @breadcrumbs = build_back_link_to_case || build_breadcrumb_structure
  end
end
