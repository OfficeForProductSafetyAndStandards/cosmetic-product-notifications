class DocumentsController < ApplicationController
  include DocumentsHelper

  before_action :set_parent
  before_action :set_document, only: %i[edit update create destroy] # TODO: do we need it for create?

  # GET /documents/1/edit
  def edit; end

  # POST /documents
  def create
    validate
    return redirect_to request.referer if @errors.present?

    save_document
  end

  # PATCH/PUT /documents/1
  def update
    validate
    return render :edit if @errors.present?

    update_document
    redirect_to @parent
  end

  # DELETE /documents/1
  def destroy
    @document.destroy
    AuditActivity::Document::Destroy.from(@document, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

private

  def set_document
    if params[:id].present?
      @document = @parent.documents.find(params[:id])
      @document_blob = @document.blob
    end
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if file_params[:title].blank?
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    if file_params[:file].blank?
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
  end

  def update_document
    @previous_data = {
        title: @document.metadata[:title],
        description: @document.metadata[:description]
    }
    update_file_details(@document_blob)
    AuditActivity::Document::Update.from(@document, @parent, @previous_data) if @parent.class == Investigation
    @document_blob.save
  end
end
