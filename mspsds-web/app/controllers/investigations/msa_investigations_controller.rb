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
    @product = params[:product].present? ? Product.new(product_step_params) : Product.new
  end

  def set_investigation
    if params[:investigation].present?
      @investigation = Investigation.new(investigation_step_params.except(:unsafe, :non_compliant))
    else
      @investigation = Investigation.new
    end
  end

  def clear_session
    session[:investigation] = nil
    session[:product] = nil
  end

  def store_investigation
    session[:investigation] = @investigation.attributes if @investigation.valid?(step)
  end

  def investigation_session_params
    session[:investigation] || {}
  end

  def product_session_params
    session[:product] || {}
  end

  def investigation_request_params
    return {} if params[:investigation].blank?

    case step
    when :why_reporting
      params.require(:investigation).permit(
          :unsafe, :hazard, :hazard_type, :hazard_description, :non_compliant, :non_compliant_reason
      )
    when :reference_number
      params.require(:investigation).permit(:reporter_reference)
    end
  end

  def product_request_params
    return {} if params[:product].blank?
    product_params
  end

  def investigation_step_params
    investigation_session_params.merge(investigation_request_params).symbolize_keys
  end

  def product_step_params
    product_session_params.merge(product_request_params).symbolize_keys
  end

  def which_businesses_params
    params.require(:businesses).permit(
      :retailer, :distributor, :importer, :manufacturer, :other, :other_business_type, :none
    )
  end

  def has_corrective_action_params
    params.permit(has_corrective_action: [:has_action])
  end

  def records_valid?
    case step
    when :product
      @product.validate
    when :why_reporting
      @investigation.errors.add(:base, "Please indicate whether the product is unsafe or non-compliant") if !product_unsafe && !product_non_compliant
      @investigation.validate_hazard_information if product_unsafe
      @investigation.validate_non_compliant_information if product_non_compliant
    when :which_businesses
      @investigation.errors.add(:base, "Please indicate which if any business is known") if no_business_selected
      @investigation.errors.add(:other_business, "type can't be blank") if no_other_business_type
    when :has_corrective_action
      @investigation.errors.add(:base, "Please indicate whether or not correction actions have been agreed or taken") if corrective_action_not_known
    when :reference_number
      @investigation.validate(step)
    end
    @investigation.errors.empty?
  end

  def product_unsafe
    investigation_step_params[:unsafe] == "1"
  end

  def product_non_compliant
    investigation_step_params[:non_compliant] == "1"
  end

  def no_business_selected
    !which_businesses_params.except(:other_business_type).values.include?("1")
  end

  def no_other_business_type
    which_businesses_params[:other] == "1" && which_businesses_params[:other_business_type].empty?
  end

  def corrective_action_not_known
    has_corrective_action_params.empty?
  end

end
