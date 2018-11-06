class FilesController < ApplicationController
  before_action :set_parent
  before_action :set_file, only: %i[edit update destroy]

  # POST /documents
  def create
    validate
    return redirect_to request.referer if @errors.present?

    save_file
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
    redirect_to @parent
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
