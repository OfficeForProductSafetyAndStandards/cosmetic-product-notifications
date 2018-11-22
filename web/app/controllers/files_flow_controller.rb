class FilesFlowController < ApplicationController
  include Wicked::Wizard
  steps :upload, :metadata

  before_action :set_parent
  before_action :set_file, only: %i[show update]

  def show;
    render_wizard
  end

  def new;
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def update
    validate
    return render step if @errors.present?

    return redirect_to next_wizard_path if step != steps.last

    save_file
  end

private

  def set_file
    @file_blob, * = load_file_attachments
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if get_attachment_metadata_params(:file).blank? && step != :upload
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    if @file_blob.blank? && step == :upload
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
    validate_blob_sizes(@file_blob, @errors) if step == :upload
  end
end
