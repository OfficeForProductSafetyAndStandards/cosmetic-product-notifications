class DocumentsController < ApplicationController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :document

  include DocumentsHelper
  include GdprHelper

  before_action :set_parent
  before_action :set_file

  # GET /documents/1/edit
  def edit; end

  # PATCH/PUT /documents/1
  def update
    previous_data = {
      title: @file_model.title,
      description: @file_model.description
    }
    if @file_model.update_file(get_attachment_metadata_params(:file))
      AuditActivity::Document::Update.from(@file_model.file, @parent, previous_data) if @parent.is_a? Investigation
      redirect_to @parent
    else
      render :edit
    end
  end

  def remove; end

  # DELETE /documents/1
  def destroy
    @file_model.detach_blob_from_list(@parent.documents)
    AuditActivity::Document::Destroy.from(@file_model.file, @parent) if @parent.is_a? Investigation
    redirect_to @parent, flash: { success: "File was successfully removed" }
  end

private

  def set_file
    file_attachment = @parent.documents.find(params[:id])
    file_blob = file_attachment.blob
    raise Pundit::NotAuthorizedError unless can_be_displayed?(file_blob, @parent)

    @file_model = Document.new(file_blob, [[:title, "Enter title"]])
  end
end
