class Investigations::PhoneCallsController < ApplicationController
  include FileConcern
  set_attachment_names :transcript
  set_file_params_key :correspondence_phone_call

  include Wicked::Wizard
  steps :context, :content, :confirmation

  before_action :set_investigation
  before_action :set_correspondence, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  before_action :store_correspondence, only: %i[update]

  def new
    clear_session
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    update_attachment
    if correspondence_valid? && @investigation.save
      attach_file
      save_attachment
      AuditActivity::Correspondence::AddPhoneCall.from(@correspondence, @investigation)
      redirect_to investigation_path @investigation, notice: 'Correspondence was successfully recorded'
    else
      redirect_to investigation_path @investigation, notice: "Correspondence could not be saved."
    end
  end

  def show
    render_wizard
  end

  def update
    update_attachment
    if correspondence_valid?
      save_attachment
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def clear_session
    session[correspondence_params_key] = nil
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_correspondence
    @correspondence = Correspondence::PhoneCall.new correspondence_params
    @investigation.association(:correspondences).add_to_target(@correspondence)
  end

  def store_correspondence
    session[correspondence_params_key] = @correspondence.attributes
  end

  def set_attachment
    @transcript_blob, * = load_file_attachments
  end

  def update_attachment
    update_blob_metadata @transcript_blob, file_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @correspondence.validate_transcript_and_content(@transcript_blob) if step == :content
    validate_blob_size(@transcript_blob, @correspondence.errors, "file")
    @correspondence.errors.empty?
  end

  def attach_file
    attach_blob_to_attachment_slot(@transcript_blob, @correspondence.transcript)
    attach_blobs_to_list(@transcript_blob, @investigation.documents)
  end

  def save_attachment
    @transcript_blob.save if @transcript_blob
  end

  def correspondence_params
    session_params.merge(request_params)
  end

  def request_params
    return {} if params[correspondence_params_key].blank?

    params.require(correspondence_params_key).permit(:correspondent_name,
                                           :phone_number,
                                           :day,
                                           :month,
                                           :year,
                                           :overview,
                                           :details)
  end

  def session_params
    session[correspondence_params_key] || {}
  end

  def file_metadata
    get_attachment_metadata_params(:transcript).merge(
      title: correspondence_params[:overview],
      description: "Call transcript"
    )
  end

  def correspondence_params_key
    "correspondence_phone_call"
  end
end
