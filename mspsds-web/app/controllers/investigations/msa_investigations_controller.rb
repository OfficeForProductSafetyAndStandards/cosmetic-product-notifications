class Investigations::MsaInvestigationsController < ApplicationController
  # include FileConcern
  include Wicked::Wizard
  include CountriesHelper
  include ProductsHelper

  steps :product, :why_reporting, :which_businesses, :has_corrective_action, :other_information, :reference_number
  before_action :set_product, except: :new
  before_action :set_investigation
  before_action :set_countries

  #GET /xxx/step
  def show
    render_wizard
  end

  # GET /xxx/new
  def new
    clear_session # functionality not implemented
    redirect_to wizard_path(steps.first)
  end

  def create
    redirect_to investigation_path(@investigation)
  end

  # PATCH/PUT /xxx
  def update
    if records_valid?
      if step == steps.last
        return create
      end
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def set_product
    @product = params[:product].present? ? Product.new(product_params) : Product.new
  end

  def set_investigation
    @investigation = params[:investigation].present? ? Investigation.new(investigation_params) : Investigation.new
  end

  def clear_session
  end

  def investigation_params
    if step == :why_reporting
      params.require(:investigation).permit(
        :unsafe, :hazard, :hazard_type, :hazard_description, :non_compliant, :non_compliant_reason
      )
    end
  end

  def records_valid?
    case step
    when :product
      @product.validate
    when :why_reporting
      @investigation.validate_hazard_information
    else
      true
    end
    @investigation.errors.empty?
  end
end
