class FilesFlowController < ApplicationController
  include Wicked::Wizard
  steps :upload, :metadata

  before_action :set_parent
  before_action :set_file, only: %i[show update]

  def show;
    render_wizard
  end

  def new
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def update
    update_blob_metadata(@file_blob, get_attachment_metadata_params(:file))
    return render step unless file_valid?

    @file_blob.save
    return redirect_to next_wizard_path unless step == steps.last

    attach_blobs_to_list(@file_blob, file_collection)
    audit_class::Add.from(@file_blob, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

private

  def set_file
    @file_blob, * = load_file_attachments
  end

  def file_valid?
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if @file_blob.blank? && step == :upload
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
    if @file_blob.metadata[:title].blank? && step != :upload
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    validate_blob_size(@file_blob, @errors, "file") if step == :upload
    @errors.empty?
  end
end
