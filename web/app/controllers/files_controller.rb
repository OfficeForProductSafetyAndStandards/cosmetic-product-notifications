class FilesController < ApplicationController
  before_action :set_parent
  before_action :set_file, only: %i[edit update destroy]

  # POST /documents
  def create
    respond_to do |format|
      validate
      if @errors.present?
        format.html { redirect_to @investigation, notice: "Failed to attach file" }
        format.json { render json: @errors, status: :unprocessable_entity }
      else
        save_file
        format.html { redirect_to @investigation, notice: "File was successfully attached." }
        format.json { render :show, status: :created, location: @activity }
      end
    end
  end

  # GET /documents/1/edit
  def edit
  end

  # PATCH/PUT /documents/1
  def update
    previous_data = {
        title: @file.metadata[:title],
        description: @file.metadata[:description]
    }
    update_blob_metadata(@file.blob, get_attachment_metadata_params(:file))

    return render :edit unless file_valid?

    @file.blob.save
    audit_class::Update.from(@file, @parent, previous_data) if @parent.class == Investigation
    redirect_to @parent
  end

  # DELETE /documents/1
  def destroy
    @file.destroy
    audit_class::Destroy.from(@file, @parent) if @parent.class == Investigation
    redirect_to @parent, notice: "File was successfully removed"
  end

private

  def set_file
    @file = file_collection.find(params[:id]) if params[:id].present?
  end

  def file_valid?
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if @file.blank? || @file.blob.blank?
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
    if @file.metadata[:title].blank?
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    validate_blob_size(@file, @errors, "file")
    @errors.empty?
  end
end
