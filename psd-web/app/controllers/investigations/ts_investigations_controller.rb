class Investigations::TsInvestigationsController < ApplicationController
  include Wicked::Wizard
  include Shared::Web::CountriesHelper
  include ProductsHelper
  include BusinessesHelper
  include CorrectiveActionsConcern
  include TestsHelper
  include FileConcern
  set_attachment_names :file
  set_file_params_key :file

  steps :product, :why_reporting, :which_businesses, :business, :has_corrective_action, :corrective_action,
        :other_information, :test_results, :risk_assessments, :product_images, :evidence_images, :other_files,
        :reference_number

  before_action :set_countries, only: %i[show create update]
  before_action :set_product, only: %i[show create update]
  before_action :set_why_reporting, only: %i[show update], if: -> { step == :why_reporting }
  before_action :set_investigation, only: %i[show create update]
  before_action :set_selected_businesses, only: %i[show update], if: -> { step == :which_businesses }
  # There is no set_pending_businesses because the business is recovered from the session in set_business
  before_action :set_business, only: %i[show update], if: -> { step == :business }
  before_action :set_skip_step, only: %i[update], if: -> do
    %i[business has_corrective_action corrective_action test_results risk_assessments product_images evidence_images other_files].include? step
  end
  before_action :set_corrective_action, only: %i[show update], if: -> { step == :corrective_action }
  # There is no set_other_information because there is no validation on the page so there is no need to set the model
  before_action :set_test, only: %i[show update], if: -> { step == :test_results }
  before_action :set_file, only: %i[show update], if: -> do
    %i[risk_assessments product_images evidence_images other_files].include? step
  end
  before_action :set_repeat_step, only: %i[show update], if: -> { step == :has_corrective_action }
  # This needs to be first to prevent other models from saving
  before_action :store_repeat_step, only: %i[update], if: -> do
    %i[has_corrective_action risk_assessments product_images evidence_images other_files].include? step
  end
  before_action :store_product, only: %i[update], if: -> { step == :product }
  before_action :store_investigation, only: %i[update], if: -> { %i[why_reporting reference_number].include? step }
  before_action :store_why_reporting, only: %i[update], if: -> { step == :why_reporting }
  before_action :store_selected_businesses, only: %i[update], if: -> { step == :which_businesses }
  before_action :store_pending_businesses, only: %i[update], if: -> { step == :which_businesses }
  before_action :store_business, only: %i[update], if: -> { step == :business }
  before_action :store_corrective_action, only: %i[update], if: -> { step == :corrective_action }
  before_action :store_other_information, only: %i[update], if: -> { step == :other_information }
  before_action :store_test, only: %i[update], if: -> { step == :test_results }
  before_action :store_file, only: %i[update], if: -> do
    %i[risk_assessments product_images evidence_images other_files].include? step
  end

  #GET /xxx/step
  def show
    case step
    when :business
      return redirect_to next_wizard_path if all_businesses_complete?
    when :corrective_action, *other_information_types
      return redirect_to next_wizard_path unless @repeat_step
    end
    # Preventing repeat step radio button from inheriting previous value
    clear_repeat_step
    render_wizard
  end

  # GET /xxx/new
  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def create
    if records_saved?
      redirect_to created_investigation_path(@investigation)
    else
      render_wizard
    end
  end

  # PATCH/PUT /xxx
  def update
    # If skipping, we've already modified session appropriately, now we need to re-render current step so usual logic
    # can kick in.
    return redirect_to wizard_path(step) if @skip_step

    if records_valid?
      case step
      when :business, :corrective_action, *other_information_types
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
    @investigation.description = @investigation.reason_created if step == :why_reporting
  end

  def set_why_reporting
    @unsafe = investigation_step_params.include?(:unsafe) ? product_unsafe : session[:unsafe]
    @non_compliant = if investigation_step_params.include?(:non_compliant)
                       product_non_compliant
                     else
                       session[:non_compliant]
                     end
  end

  def set_selected_businesses
    if params.has_key?(:businesses)
      @selected_businesses = which_businesses_params
                                 .select { |key, selected| key != :other_business_type && selected == "1" }
                                 .keys
      @other_business_type = which_businesses_params[:other_business_type]
    else
      @selected_businesses = session[:selected_businesses]
      @other_business_type = session[:other_business_type]
    end
  end

  def set_business
    @business = Business.new business_step_params
    @business.contacts.build unless @business.primary_contact
    @business.locations.build unless @business.primary_location
    defaults_on_primary_location @business
    next_business = session[:businesses].find { |entry| entry[:business].nil? }
    @business_type = next_business ? next_business[:type] : nil
  end

  def set_skip_step
    # Ideally we'd use the "value" of the button here, separate from the literally displayed text, but due to
    # differences in how this is handled between ie8 and normal browsers, that's not practical
    @skip_step = true if params[:commit] == "Skip this page"
  end

  def set_repeat_step(model = :investigation)
    repeat_step_key = further_key step
    @repeat_step = case params.dig(model, repeat_step_key)
                   when "Yes"
                     true
                   when "No"
                     false
                   when nil
                     session[repeat_step_key]
                   end
  end

  def set_corrective_action
    @corrective_action = @investigation.corrective_actions.build(corrective_action_params)
    @corrective_action.set_dates_from_params(params[:corrective_action])
    @corrective_action.product = @product
    file_blob, * = load_file_attachments :corrective_action
    @file_model = Document.new(file_blob)
    if file_blob && @corrective_action.related_file == "Yes"
      @file_model.attach_blob_to_list(@corrective_action.documents)
    end
    set_repeat_step(:corrective_action)
  end

  def set_test
    @test = @investigation.tests.build(test_params)
    @test.set_dates_from_params(params[:test])
    @test.product = @product
    file_blob, * = load_file_attachments :test
    @file_model = Document.new(file_blob, [[:file, "Provide test file"]])
    @file_model.attach_blob_to_list(@test.documents) if file_blob
    set_repeat_step(:test)
  end

  def all_businesses_complete?
    session[:businesses].all? { |entry| entry[:business].present? }
  end

  def set_file
    file_blob, * = load_file_attachments
    @file_model = Document.new(file_blob, [[:file, "Upload file"], [:title, "Enter file title"], [:description, "Enter file description"]])
    set_repeat_step :file
  end

  def clear_session
    session.delete :investigation
    session.delete :product
    session.delete :unsafe
    session.delete :non_compliant
    session.delete :other_business_type
    session.delete :further_corrective_action
    other_information_types.each do |type|
      session.delete further_key(type)
    end
    session[:corrective_actions] = []
    session[:test_results] = []
    session[:files] = []
    session[:product_files] = []
    session.delete :file
    session[:selected_businesses] = []
    session[:businesses] = []
  end

  def store_investigation
    session[:investigation] = @investigation.attributes if @investigation.valid?(step)
  end

  def store_product
    if @product.valid?(step)
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
      params[:investigation][:hazard_description] = nil unless params[:investigation][:unsafe] == "1"
      params[:investigation][:hazard_type] = nil unless params[:investigation][:unsafe] == "1"
      params[:investigation][:non_compliant_reason] = nil unless params[:investigation][:non_compliant] == "1"
      params.require(:investigation).permit(
        :unsafe, :hazard_type, :hazard_description, :non_compliant, :non_compliant_reason
      )
    when :reference_number
      params[:investigation][:complainant_reference] = nil unless params[:investigation][:has_complainant_reference] == "Yes"
      params.require(:investigation).permit(:complainant_reference)
    else
      {}
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
    # TODO PSD-980 use this to retrieve a business for editing eg for browser back button
    {}
  end

  def corrective_action_session_params
    # TODO PSD-980 use this to retrieve a corrective action for editing eg for browser back button
    {}
  end

  def test_session_params
    # TODO PSD-980 use this to retrieve a test for editing eg for browser back button
    { type: Test::Result.name }
  end

  def which_businesses_params
    params.require(:businesses).permit(
      :retailer, :distributor, :importer, :manufacturer, :other, :other_business_type, :none
    )
  end

  def other_information_params
    params.require(:information).permit(*other_information_types)
  end

  def reference_number_params
    params.require(:investigation).permit(:has_complainant_reference, :complainant_reference)
  end

  def other_information_types
    %i[test_results risk_assessments product_images evidence_images other_files]
  end

  def store_selected_businesses
    session[:selected_businesses] = @selected_businesses
    session[:other_business_type] = @other_business_type
  end

  def store_pending_businesses
    if which_businesses_params[:none] == "1"
      session[:businesses] = []
    else
      businesses = which_businesses_params
                       .select { |relationship, selected| relationship != "other" && selected == "1" }
                       .keys
      businesses << which_businesses_params[:other_business_type] if which_businesses_params[:other] == "1"
      session[:businesses] = businesses.map { |type| { type: type, business: nil } }
    end
  end

  def store_why_reporting
    session[:unsafe] = @unsafe
    session[:non_compliant] = @non_compliant
  end

  def store_business
    current_business_type = params.require(:business)[:business_type]
    if @skip_step
      session[:businesses].delete_if { |entry| entry[:type] == current_business_type }
      return
    end
    if @business.valid?
      business_entry = session[:businesses].find { |entry| entry[:type] == current_business_type }
      contact = @business.contacts.first
      location = @business.locations.first
      if contact.attributes.values.any?(&:present?)
        business_entry[:contact] = contact.attributes if contact.valid?
      end
      # Defaults_on_primary_location adds a default value to the location name field but we don't want to consider this
      # value when determining if the location form has been completed
      if location.attributes.reject { |k, _| k == "name" }.values.any?(&:present?)
        business_entry[:location] = location.attributes if location&.valid?
      end
      business_entry[:business] = @business.attributes
    end
  end

  def store_repeat_step
    if @skip_step
      session[further_key(step)] = false
      return
    end

    if repeat_step_valid?(@investigation)
      session[further_key(step)] = @repeat_step
    end
  end

  def repeat_step_valid?(model)
    if @repeat_step.nil?
      further_page_type = to_item_text(step)
      model.errors.add(further_key(step), "Select whether or not you have #{further_page_type} to record")
      return false
    end
    true
  end

  def store_corrective_action
    return if @skip_step

    @file_model.update_file corrective_action_file_metadata
    return unless corrective_action_valid?

    session[:corrective_actions] << { corrective_action: @corrective_action.attributes, file_blob_id: @file_model.file&.id }
    session.delete :file
    session[further_key(step)] = @repeat_step
  end

  def corrective_action_valid?
    @corrective_action.validate
    @file_model.validate
    repeat_step_valid?(@corrective_action)
    @corrective_action.errors.empty? && @file_model.errors.empty?
  end

  def store_test
    return if @skip_step

    @file_model.update_file test_file_metadata
    return unless test_valid?

    session[:test_results] << { test: @test.attributes, file_blob_id: @file_model.file&.id }
    session.delete :file
    session[further_key(step)] = @repeat_step
  end

  def test_valid?
    @test.validate
    @file_model.validate
    repeat_step_valid?(@test)
    @test.errors.empty? && @file_model.errors.empty?
  end

  def store_file
    return if @skip_step

    if @file_model.update_file(get_attachment_metadata_params(:file))
      if step == :product_images
        session[:product_files] << @file_model.file&.id
      else
        session[:files] << @file_model.file&.id
      end
      session.delete :file
    end
  end

  def store_other_information
    other_information_types.each do |key|
      session[further_key(key)] = other_information_params[key] == "1"
    end
  end

  # We use 'further' to refer to the boolean flags indicating
  # whether the user wants to provide another entry of a given type
  def further_key(key)
    if key == :has_corrective_action
      :further_corrective_action
    else
      ("further_" + key.to_s).to_sym
    end
  end

  def to_item_text(key)
    if key == :has_corrective_action
      "corrective action"
    else
      "further " + key.to_s.humanize(capitalize: false)
    end
  end

  def records_valid?
    case step
    when :product
      @product.validate
    when :why_reporting
      @investigation.errors.add(:why_reporting, "Indicate whether the product is unsafe or non-compliant") if !product_unsafe && !product_non_compliant
      @investigation.validate :unsafe if product_unsafe
      @investigation.validate :non_compliant if product_non_compliant
    when :which_businesses
      validate_none_as_only_selection
      @investigation.errors.add(:which_business, "Indicate which if any business is known") if no_business_selected
      @investigation.errors.add(:other_business_type, "Enter other business type") if no_other_business_type
    when :business
      if @business.errors.any? || @business.contacts_have_errors? || @business.locations_have_errors?
        return false
      end
    when :corrective_action
      return false if @corrective_action.errors.any?
    when :test_results
      return false if @test.errors.any?
    when :reference_number
      if reference_number_params[:has_complainant_reference].blank?
        @investigation.errors.add(:has_complainant_reference, "Choose whether you want to add your own reference number")
      end
      if reference_number_params[:has_complainant_reference] == "Yes" && @investigation.complainant_reference.blank?
        @investigation.errors.add(:complainant_reference, "Enter existing reference number")
        @has_reference_number = reference_number_params[:has_complainant_reference]
      end
    end
    return false if @file_model&.errors&.any?

    @investigation.errors.empty? && @product.errors.empty?
  end

  def validate_none_as_only_selection
    if @selected_businesses.include?("none") && @selected_businesses.length > 1
      @investigation.errors.add(:none, "Select none only if not selecting other businesses")
    end
  end

  def records_saved?
    return false unless records_valid?

    @product.save
    @investigation.products << @product
    @investigation.save
    save_businesses
    save_corrective_actions
    save_test_results
    save_product_files
    save_files
  end

  def save_businesses
    session[:businesses].each do |session_business|
      business = Business.create!(session_business[:business])
      if session_business[:contact]
        business.contacts << Contact.new(session_business[:contact])
      end
      if session_business[:location]
        business.locations << Location.new(session_business[:location])
      end
      @investigation.add_business(business, session_business[:type])
    end
  end

  def save_corrective_actions
    session[:corrective_actions].each do |session_corrective_action|
      action_record = CorrectiveAction.new(session_corrective_action[:corrective_action])
      action_record.product = @product
      file_blob = ActiveStorage::Blob.find_by(id: session_corrective_action[:file_blob_id])
      if file_blob
        file_model = Document.new(file_blob)
        file_model.attach_blob_to_list(action_record.documents)
        file_model.attach_blob_to_list(@investigation.documents)
      end
      @investigation.corrective_actions << action_record
    end
  end

  def save_test_results
    session[:test_results].each do |session_test_result|
      test_record = Test::Result.new(session_test_result[:test])
      test_record.product = @product
      file_blob = ActiveStorage::Blob.find_by(id: session_test_result[:file_blob_id])
      if file_blob
        file_model = Document.new(file_blob)
        file_model.attach_blob_to_list(test_record.documents)
        file_model.attach_blob_to_list(@investigation.documents)
      end
      @investigation.tests << test_record
    end
  end

  def save_files
    session[:files].each do |file_blob_id|
      file_blob = ActiveStorage::Blob.find_by(id: file_blob_id)
      file_model = Document.new(file_blob)
      file_model.attach_blob_to_list(@investigation.documents)
      AuditActivity::Document::Add.from(file_blob, @investigation)
    end
  end

  def save_product_files
    session[:product_files].each do |file_blob_id|
      file_blob = ActiveStorage::Blob.find_by(id: file_blob_id)
      file_model = Document.new(file_blob)
      file_model.attach_blob_to_list(@product.documents)
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

  def clear_repeat_step
    @repeat_step = nil
    session.delete further_key(step)
  end
end
