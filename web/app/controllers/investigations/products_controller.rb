class Investigations::ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper

  before_action :set_investigation, only: %i[index new create suggested add destroy]
  before_action :set_product, only: %i[destroy]
  before_action :create_product, only: %i[new create suggested]
  before_action :set_countries, only: %i[new]

  # GET /investigations/1/products
  def index; end

  # GET /investigations/1/products/new
  def new;
    excluded_product_ids = @investigation.products.map(&:id)
    @products = advanced_product_search(@product, excluded_product_ids)
  end

  # POST /investigations/1/products/add
  def add
    product = Product.find(params[:product_id])
    @investigation.products << product
    AuditActivity.create(
        title: product.name,
        subtitle_slug: "Product added",
        product: product,
        description: "Product desc",
        source: UserSource.new(user: current_user),
        investigation: @investigation)
    redirect_to @investigation, notice: "Product was successfully added."
  end

  # GET /investigations/1/products/suggested
  def suggested
    excluded_product_ids = params[:excluded_products].split(",").map(&:to_i)
    @products = advanced_product_search(@product, excluded_product_ids)
    render partial: "products/suggested"
  end

  # POST /investigations/1/products
  def create
    respond_to do |format|
      if @investigation.products << @product
        AuditActivity.create(
            title: @product.name,
            subtitle_slug: "Product added",
            product: @product,
            description: "Product desc",
            source: UserSource.new(user: current_user),
            investigation: @investigation)
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
end
