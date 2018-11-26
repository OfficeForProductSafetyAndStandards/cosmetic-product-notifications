class Investigations::MeetingsController < ApplicationController
  include FileConcern
  set_attachment_names :transcript, :related_attachment
  set_file_params_key :correspondence

  include Wicked::Wizard
  steps :context, :content, :confirmation

  before_action :set_investigation
  before_action :set_correspondence, only: %i[show create update]
  before_action :set_attachments, only: %i[show create update]
  before_action :store_correspondence, only: %i[update]

  def new
    clear_session
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    update_attachments
    if correspondence_valid? && @investigation.save
      attach_files
      save_attachments
      AuditActivity::Correspondence::AddMeeting.from(@correspondence, @investigation)
      redirect_to investigation_path @investigation, notice: 'Correspondence was successfully recorded'
    else
      redirect_to investigation_path @investigation, notice: "Correspondence could not be saved."
    end
  end

  def show
    render_wizard
  end

  def update
    update_attachments
    if correspondence_valid?
      save_attachments
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def clear_session
    session[:correspondence] = nil
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_correspondence
    @correspondence = @investigation.correspondences.build(correspondence_params)
  end

  def store_correspondence
    session[:correspondence] = @correspondence.attributes
  end

  def set_attachments
    @transcript_blob, @related_attachment_blob = load_file_attachments
  end

  def update_attachments
    update_blob_metadata @transcript_blob, transcript_metadata
    update_blob_metadata @related_attachment_blob, related_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    validate_blob_size(@transcript_blob, @correspondence.errors, "transcript")
    validate_blob_size(@related_attachment_blob, @correspondence.errors, "related attachment")
    @correspondence.errors.empty?
  end

  def attach_files
    attach_blob_to_attachment_slot(@transcript_blob, @correspondence.transcript)
    attach_blob_to_attachment_slot(@related_attachment_blob, @correspondence.related_attachment)
    attach_blobs_to_list(@transcript_blob, @related_attachment_blob, @investigation.documents)
  end

  def save_attachments
    @transcript_blob.save if @transcript_blob
    @related_attachment_blob.save if @related_attachment_blob
  end

  def correspondence_params
    session_params.merge(request_params)
  end

  def request_params
    return {} if params[:correspondence].blank?

    params.require(:correspondence).permit(:correspondent_name,
                                           :phone_number,
                                           :day,
                                           :month,
                                           :year,
                                           :overview,
                                           :details)
  end

  def session_params
    session[:correspondence] || suggested_values
  end

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end

  def transcript_metadata
    get_attachment_metadata_params(:transcript).merge(
      title: correspondence_params["overview"],
      description: "Call transcript"
    )
  end

  def related_attachment_metadata
    get_attachment_metadata_params(:related_attachment).merge(
      title: correspondence_params["overview"]
    )
  end
end
