class Investigations::CreationFlowController < ApplicationController
  include FileConcern
  include Wicked::Wizard

  before_action :set_page_title, only: %i[show create update]
  before_action :set_complainant, only: %i[show create update]
  before_action :set_investigation, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  before_action :update_attachment, only: %i[create update]
  # before_action :assign_about_enquiry, only: :update, if: -> { step == :about_enquiry}
  before_action :store_investigation, only: %i[update]
  before_action :store_complainant, only: %i[update], if: -> { step != :about_enquiry}

  # GET /xxx/step
  def show
    render_wizard
  end

  # GET /xxx/new
  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /xxx
  def create
    if investigation_saved?
      redirect_to investigation_path(@investigation), flash: { success: success_message }
    else
      render step
    end
  end

  # PATCH/PUT /xxx
  # def update
  #   if investigation_valid?
  #     if step == steps.last
  #       create
  #     else
  #       redirect_to next_wizard_path
  #     end
  #   else
  #     render step
  #   end
  # end
  # PATCH/PUT /xxx
  def update
    if investigation_valid?
      if step == steps.last
        create
      else
        redirect_to next_wizard_path
      end
    else
      render step
    end
  end


private

  def model_key
    # This needs to be defined by any controller that inherits from this class.
  end

  def model_params
    # These need to be defined by any controller that inherits from this class.
  end

  def success_message
    # This needs to be defined by any controller that inherits from this class.
  end

  def set_page_title
    # This needs to be defined by any controller that inherits from this class.
  end

  def clear_session
    session[:complainant] = nil
    session[model_key] = nil
    initialize_file_attachments
  end

  def set_complainant
    @complainant = Complainant.new(complainant_params)
  end

  def set_investigation
    # This needs to be defined by any controller that inherits from this class.
  end

  def set_attachment
    @file_blob, * = load_file_attachments
  end

  def update_attachment
    update_blob_metadata @file_blob, attachment_metadata
  end

  def store_complainant
    session[:complainant] = @complainant.attributes if @complainant.valid?(step)
  end

  def store_investigation
    p "Store inv"
    session[model_key] = @investigation.attributes if @investigation.valid?(step)
  end

  # def investigation_valid?
  #   if step == :about_enquiry
  #     p "inside"
  #     if !session[:date_received].nil?
  #       @investigation.errors.add(:date_received, "Enter date received")
  #       @investigation.validate(step)
  #     end
  #   else
  #     @complainant.validate(step) unless step == "about_enquiry"
  #     @investigation.validate(step)
  #     validate_blob_size(@file_blob, @investigation.errors, "File")
  #   end
  #   @complainant.errors.empty? &&
  #   @investigation.errors.empty?
  # end

  def investigation_valid?
    p "step enquiry?"
    p step != :about_enquiry
    # if (step != :about_enquiry) then @complainant.validate(step) end
    @investigation.validate(step)
    validate_blob_size(@file_blob, @investigation.errors, "File")
    p @complainant.errors
    @complainant.errors.empty? && @investigation.errors.empty?
  end

  def investigation_saved?
    return false unless investigation_valid?

    attach_blobs_to_list(@file_blob, @investigation.documents)
    @investigation.complainant = @complainant
    @investigation.save
  end

  def complainant_params
    complainant_session_params.merge(complainant_request_params)
  end

  def investigation_params
    investigation_session_params.merge(investigation_request_params)
  end

  def complainant_session_params
    session[:complainant] || {}
  end

  def investigation_session_params
    session[model_key] || {}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def complainant_request_params
    return {} if params[:complainant].blank?

    params.require(:complainant).permit(:complainant_type, :name, :phone_number, :email_address, :other_details)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def investigation_request_params
    return {} if params[model_key].blank?

    params.require(model_key).permit(model_params)
  end

  def attachment_metadata
    get_attachment_metadata_params(:file).merge(
      title: @file_blob&.filename
    )
  end

  # def assign_about_enquiry
  #   session[:date_received] = params[:date_received] == "other" ? investigation_params[:other_date] : investigation_params[:date_received]
  # end
end
