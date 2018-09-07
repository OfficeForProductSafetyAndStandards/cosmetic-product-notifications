class DocumentsController < ApplicationController
  include DocumentsHelper

  before_action :authenticate_user!
  before_action :set_parent
  before_action :set_document, only: %i[show edit update destroy]
  before_action :create_document, only: %i[create]
  before_action :update_document, only: %i[update]

  helper_method :associated_document_path
  helper_method :associated_documents_path
  helper_method :new_associated_document_path
  helper_method :edit_associated_document_path

  # GET /documents
  # GET /documents.json
  def index
    @documents = @parent.documents.attachments
  end

  # GET /documents/1
  # GET /documents/1.json
  def show; end

  # GET /documents/new
  def new; end

  # GET /documents/1/edit
  def edit; end

  # POST /documents
  # POST /documents.json
  def create
    respond_to do |format|
      if @document
        format.html { redirect_to edit_associated_document_path(@parent, @document) }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.blob.save
        format.html { redirect_to action: "index", notice: "Document was successfully saved." }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.purge_later
    respond_to do |format|
      format.html { redirect_to action: "index", notice: "Document was successfully deleted." }
      format.json { head :no_content }
    end
  end

private

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def set_document
    @document = @parent.documents.find(params[:id]) if @parent.present?
  end

  def create_document
    @documents = @parent.documents.attach(document_params[:file])
    @document = @documents.last
  end

  def update_document
    @document.blob.metadata.update(document_params)
    @document.blob.metadata["updated"] = Time.current
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:file, :title, :description, :document_type, :other_type)
  end
end
