class ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  helper_method :sort_column, :sort_direction

  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy]
  before_action :create_product, only: %i[create]
  before_action :set_countries, only: %i[new edit]

  # GET /products
  # GET /products.json
  def index
    @products = search_for_products
  end

  # GET /products/suggested
  def suggested
    @products = advanced_product_search
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

  # If the user supplies a barcode and it matches, then just return that.
  # Otherwise use the general query param
  def advanced_product_search
    gtin_search_results = search_for_gtin if params[:gtin].present?
    # if there was no GTIN param or there were no results for the GTIN search
    basic_search_results = search_for_products if gtin_search_results.blank? && params[:q].present?
    basic_search_results || gtin_search_results || []
  end

  def search_for_products
    products = if params[:q].blank?
                 Product.all
               else
                 Product.search(params[:q]).records
               end
    products.reorder("#{sort_column} #{sort_direction}").paginate(page: params[:page], per_page: 20)
  end

  def search_for_gtin
    Product.search(query: { match: { gtin: params[:gtin] } })
           .paginate(page: params[:page], per_page: 20).records
  end

  # Use callbacks to share common setup or constraints between actions.
  def create_product
    @product = Product.new(product_params)
    @product.source = UserSource.new(user: current_user)
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def sort_column
    Product.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(
      :gtin, :name, :description, :model, :batch_number, :url_reference, :brand, :serial_number,
      :manufacturer, :country_of_origin, :date_placed_on_market, :associated_parts,
      images_attributes: %i[id title url _destroy]
    )
  end

  def set_countries
    @countries = all_countries
  end
end
