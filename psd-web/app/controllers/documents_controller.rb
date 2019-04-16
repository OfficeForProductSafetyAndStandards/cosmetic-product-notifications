class DocumentsController < ApplicationController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :document

  include DocumentsHelper
  include GdprHelper

  before_action :set_parent
  before_action :set_file, only: %i[edit update remove destroy]

  # GET /documents/1/edit
  def edit; end

  # PATCH/PUT /documents/1
  def update
    previous_data = {
      title: @file_model.title,
      description: @file_model.description
    }
    if @file_model.update(get_attachment_metadata_params(:file), :metadata)
      AuditActivity::Document::Update.from(@file_model.get_blob, @parent, previous_data) if @parent.is_a? Investigation
      redirect_to @parent
    else
      render :edit
    end
  end

  def remove; end

  # DELETE /documents/1
  def destroy
    @file_model.detach_blob_from_list(@parent.documents)
    AuditActivity::Document::Destroy.from(@file_model.get_blob, @parent) if @parent.is_a? Investigation
    redirect_to @parent, flash: { success: "File was successfully removed" }
  end

private

  def set_file
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    file = @parent.documents.find(params[:id]) if params[:id].present?
    raise Pundit::NotAuthorizedError unless can_be_displayed?(file, @parent)
    @file_model = Document.new(file)
  end
end
