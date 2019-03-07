class BusinessesController < ApplicationController
  include BusinessesHelper
  include UrlHelper
  include Shared::Web::CountriesHelper
  helper_method :sort_column, :sort_direction

  before_action :set_search_params, only: %i[index]
  before_action :set_business, only: %i[show edit update]
  before_action :update_business, only: %i[update]
  before_action :build_breadcrumbs, only: %i[show]
  before_action :set_countries, only: %i[update edit]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = search_for_businesses(20)
  end

  # GET /businesses/1
  # GET /businesses/1.json
  def show; end

  # GET /businesses/1/edit
  def edit
    @business.locations.build unless @business.locations.any?
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: "Business was successfully updated." }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def update_business
    @business.assign_attributes(business_params)
    defaults_on_primary_location(@business) if @business.locations.any?
  end

  def build_breadcrumbs
    @breadcrumbs = build_back_link_to_case || build_breadcrumb_structure
  end
end
