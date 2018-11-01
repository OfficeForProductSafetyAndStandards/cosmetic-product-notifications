class ImagesController < ApplicationController
  include ImagesHelper

  before_action :set_parent
  before_action :set_image, only: %i[edit update create]

  # GET /images/1/edit
  def edit; end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    validate
    return render if @errors.present?

    update_image
    @image_blob.save
    redirect_to @parent
  end

  # POST /images
  # POST /images.json
  def create
    validate
    return redirect_to request.referer if @errors.present?

    save_image
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @parent.images.find(params[:id]).purge_later
    redirect_to @parent
  end

private

  def set_image
    if params[:id].present?
      @image = @parent.images.find(params[:id])
      @image_blob = @image.blob
      session[:image_blob_id] = @image_blob.id
    elsif session[:image_blob_id]
      @image_blob = ActiveStorage::Blob.find_by(id: session[:image_blob_id])
    end
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if image_params[:title].blank?
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
  end
end
