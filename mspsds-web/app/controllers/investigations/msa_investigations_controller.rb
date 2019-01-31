class Investigations::MsaInvestigationsController < ApplicationController
  include Wicked::Wizard
  include CountriesHelper
  include ProductsHelper
  include BusinessesHelper
  include CorrectiveActionsHelper
  include TestsHelper
  include FileConcern
  set_attachment_names :file
  set_file_params_key :corrective_action

  steps :product, :why_reporting, :which_businesses, :business, :has_corrective_action, :corrective_action,
        :other_information, :test_results, :reference_number
  before_action :set_product, only: %i[show create update]
  before_action :set_investigation, only: %i[show create update]
  before_action :set_countries, only: %i[show create update]
  before_action :store_product, only: %i[update]
  before_action :store_investigation, only: %i[update]

  #GET /xxx/step
  def show
    case step
    when :business
      next_selected_business = session_businesses.find { |entry| entry["business"].nil? }
      if next_selected_business
        @business_type = next_selected_business["type"]
        set_business
      else
        return redirect_to next_wizard_path
      end
    when :corrective_action
      set_corrective_action
      set_attachment
      unless session[:corrective_action_pending]
        return redirect_to next_wizard_path
      end
    when :test_results
      set_test
      unless session[:test_results_pending]
        return redirect_to next_wizard_path
      end
    end
    render_wizard
  end

  # GET /xxx/new
  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def create
    if records_saved?
      redirect_to investigation_path(@investigation)
    else
      render_wizard
    end
  end

  # PATCH/PUT /xxx
  def update
    if records_valid?
      case step
      when :which_businesses
        set_session_businesses selected_businesses
      when :business
        store_business
        return redirect_to wizard_path step
      when :has_corrective_action
        store_corrective_action_pending
      when :corrective_action
        store_corrective_action
        store_corrective_action_pending
        return redirect_to wizard_path step
      when :other_information
        store_other_information
      when :test_results
        session[:test_results_pending] = params.permit(:has_test_results)[:has_test_results] = "Yes"
        return redirect_to wizard_path step
      when steps.last
        return create
      end
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

private

  def set_product
    @product = Product.new(product_step_params)
  end

  def set_investigation
    @investigation = Investigation.new(investigation_step_params.except(:unsafe, :non_compliant))
  end

  def set_business
    @business = Business.new business_step_params
    @business.locations.build
    @business.build_contact
  end

  def clear_session
    session.delete :investigation
    session.delete :product
    session[:corrective_actions] = []
    session[:test_results] = []
    session.delete :file
    set_session_businesses([])
  end

  def store_investigation
    session[:investigation] = @investigation.attributes if changed_investigation && @investigation.valid?(step)
  end

  def store_product
    if changed_product && @product.valid?(step)
      session[:product] = @product.attributes
    end
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

  def business_request_params
    return {} if params[:business].blank?

    business_params
  end

  def investigation_step_params
    investigation_session_params.merge(investigation_request_params).symbolize_keys
  end

  def product_step_params
    product_session_params.merge(product_request_params).symbolize_keys
  end

  def business_step_params
    business_session_params.merge(business_request_params).symbolize_keys
  end

  def business_session_params
    # TODO use this to retrieve a business for editing eg for browser back button
    {}
  end

  def corrective_action_session_params
    # TODO use this to retrieve a corrective action for editing eg for browser back button
    {}
  end

  def test_session_params
    # TODO use this to retrieve a test for editing eg for browser back button
    { type: Test::Result.name }
  end

  def which_businesses_params
    params.require(:businesses).permit(
      :retailer, :distributor, :importer, :manufacturer, :other, :other_business_type, :none
    )
  end

  def other_information_params
    params.permit(*other_information_types)
  end

  def other_information_types
    [:test_results, :risk_assessments, :product_images, :evidence_images, :other_files]
  end

  def session_businesses
    session[:selected_businesses]
  end

  def set_session_businesses new_value
    session[:selected_businesses] = new_value
  end

  def store_business
    business_entry = session_businesses.find { |entry| entry["type"] == params.require(:business)[:business_type] }
    business_entry["business"] = Business.new business_step_params
  end

  def store_corrective_action
    set_corrective_action
    set_attachment
    update_attachment
    @file_blob.save if @file_blob
    session[:corrective_actions] << { corrective_action: @corrective_action, file_blob_id: @file_blob&.id }
    # Delete these objects in session having saved them. This allows us to loop round and use the same keys for the a
    # different record created with the same step
    session.delete :file
    session.delete :corrective_action
  end

  def selected_businesses
    return {} if which_businesses_params["none"] == "1"

    businesses = which_businesses_params.select { |relationship, selected| relationship != "other" && selected == "1" }.keys
    businesses << which_businesses_params[:other_business_type] if which_businesses_params[:other] == "1"
    businesses.map { |type| { type: type, business: nil } }
  end

  def pending_corrective_action_params
    params.permit(:has_action)
  end

  def store_corrective_action_pending
    session[:corrective_action_pending] = pending_corrective_action_params[:has_action] == "Yes"
  end

  def store_other_information
    other_information_types.each do |info|
      pending_symbol = (info.to_s + "_pending").to_sym
      session[pending_symbol] = other_information_params[info] == "1"
    end
  end

  def records_valid?
    case step
    when :product
      @product.validate
    when :why_reporting
      @investigation.errors.add(:base, "Please indicate whether the product is unsafe or non-compliant") if !product_unsafe && !product_non_compliant
      @investigation.validate :unsafe if product_unsafe
      @investigation.validate :non_compliant if product_non_compliant
    when :which_businesses
      @investigation.errors.add(:base, "Please indicate which if any business is known") if no_business_selected
      @investigation.errors.add(:other_business, "type can't be blank") if no_other_business_type
    when :has_corrective_action
      @investigation.errors.add(:base, "Please indicate whether or not correction actions have been agreed or taken") if corrective_action_not_known
    end
    @investigation.errors.empty? && @product.errors.empty?
  end

  def records_saved?
    return false unless records_valid?

    if !@product.save
      return false
    end

    if !@investigation.save
      return false
    end

    @investigation.products << @product

    save_businesses
    save_corrective_actions
  end

  def save_corrective_actions
    session[:corrective_actions].each do |session_corrective_action|
      action_record = CorrectiveAction.new(session_corrective_action["corrective_action"])
      action_record.product = @product
      if file_blob = ActiveStorage::Blob.find_by(id: session_corrective_action["file_blob_id"])
        attach_blobs_to_list(file_blob, action_record.documents)
        attach_blobs_to_list(file_blob, @investigation.documents)
      end
      @investigation.corrective_actions << action_record
    end
  end

  def save_businesses
    session_businesses.each do |session_business|
      business = Business.create(session_business["business"])
      @investigation.add_business(business, session_business["type"])
    end
  end

  def product_unsafe
    investigation_step_params[:unsafe] == "1"
  end

  def product_non_compliant
    investigation_step_params[:non_compliant] == "1"
  end

  def no_business_selected
    !which_businesses_params.except(:other_business_type).value?("1")
  end

  def no_other_business_type
    which_businesses_params[:other] == "1" && which_businesses_params[:other_business_type].empty?
  end

  def corrective_action_not_known
    pending_corrective_action_params.empty?
  end

  def changed_investigation
    %i[why_reporting reference_number].include? step
  end

  def changed_product
    step == :product
  end
end
