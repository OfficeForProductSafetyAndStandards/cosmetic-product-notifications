class DocumentsController < ApplicationController
  include DocumentsHelper

  before_action :set_parent
  before_action :set_document, only: %i[edit update create destroy] # TODO: do we need it for create?

  helper_method :associated_document_path
  helper_method :associated_documents_path
  helper_method :new_associated_document_path
  helper_method :edit_associated_document_path

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

  # Never trust parameters from the scary internet, only allow the white list through.
  # TODO: handle document type and other type somehow
  # is it better to have an overridable file_params?
  # or to handle all the logic inside of file concern?
  def document_params
    params.require(:document).permit(:file, :title, :description, :document_type, :other_type)
  end
end
