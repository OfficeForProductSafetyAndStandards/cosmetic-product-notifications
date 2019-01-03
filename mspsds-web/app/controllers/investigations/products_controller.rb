class Investigations::ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper

  before_action :set_investigation
  before_action :set_product, only: %i[link remove unlink]
  before_action :create_product, only: %i[new create suggested]
  before_action :set_countries, only: %i[new]

  include Pundit
  before_action do
    authorize @investigation, :visible?
  end

  # GET /cases/1/products/new
  def new
    excluded_product_ids = @investigation.products.map(&:id)
    @products = advanced_product_search(@product, excluded_product_ids)
  end

  # GET /cases/1/products/suggested
  def suggested
    excluded_product_ids = params[:excluded_products].split(",").map(&:to_i)
    @products = advanced_product_search(@product, excluded_product_ids)
    render partial: "products/suggested"
  end

  # POST /cases/1/products
  def create
    respond_to do |format|
      if @product.valid?
        @investigation.products << @product
        format.html { redirect_to_investigation_products_tab "Product was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        set_countries
        @products = advanced_product_search(@product, @investigation.products.map(&:id))
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cases/1/products/2
  def link
    @investigation.products << @product
    redirect_to_investigation_products_tab "Product was successfully linked."
  end

  def remove; end

  # DELETE /cases/1/products
  def unlink
    @investigation.products.delete(@product)
    respond_to do |format|
      format.html do
        redirect_to_investigation_products_tab "Product was successfully removed."
      end
      format.json { head :no_content }
    end
  end

private

  def redirect_to_investigation_products_tab(notice)
    redirect_to investigation_path(@investigation, anchor: "products"), notice: notice
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end
end
