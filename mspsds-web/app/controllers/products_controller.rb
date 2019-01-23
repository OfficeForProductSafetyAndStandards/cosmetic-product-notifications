class ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_product, only: %i[show edit update destroy]
  before_action :create_product, only: %i[new create suggested]
  before_action :set_countries, only: %i[create update new edit]

  # GET /products
  # GET /products.json
  def index
    @products = search_for_products(20)
  end

  # GET /products/suggested
  def suggested
    @products = advanced_product_search(@product)
    render partial: "suggested"
  end

  # GET /products/1
  # GET /products/1.json
  def show
    build_breadcrumbs
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @product.id.to_s
      end
    end
  end

  # GET /products/new
  def new
    @products = advanced_product_search(@product)
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
      format.html { redirect_to products_url, notice: "Product was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def build_breadcrumbs
    @breadcrumbs = { is_simple_link: request.referrer.match?(/cases\//) }
    if @breadcrumbs[:is_simple_link]
      @breadcrumbs = @breadcrumbs.merge(build_back_link_to_case)
    else
      @breadcrumbs = @breadcrumbs.merge(build_breadcrumb_structure)
    end
  end

  def build_back_link_to_case
    case_id = request.referrer.split(/cases\//)[1].split(/[?\/#]/)[0]
    kase = Investigation.find(case_id)
    {
      simple_link_text: "Bask to #{kase.pretty_description}",
      link_to: kase
    }
  end

  def build_breadcrumb_structure
   {
     ancestors: [
      {
        name: "Products",
        path: products_path
      }
    ],
    current: {
      name: @product.name
    }
   }
  end
end
