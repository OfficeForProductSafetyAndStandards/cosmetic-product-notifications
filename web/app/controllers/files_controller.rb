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
  def edit; end

  # PATCH/PUT /documents/1
  def update
    validate
    return render :edit if @errors.present?

    update_file
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
    if params[:id].present?
      @file = file_collection.find(params[:id])
      @file_blob = @file.blob
    end
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if file_params[:title].blank?
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    if file_params[:file].blank? && !@file
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
    validate_blob_size(@file_blob, @errors)
  end

  def update_file
    @previous_data = {
      title: @file.metadata[:title],
      description: @file.metadata[:description]
    }
    update_file_details(@file_blob)
    audit_class::Update.from(@file, @parent, @previous_data) if @parent.class == Investigation
    @file_blob.save
  end
end
