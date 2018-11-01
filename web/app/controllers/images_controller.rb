class ImagesController < ApplicationController
  include ImagesHelper

  before_action :set_parent
  before_action :set_image, only: %i[edit create]

  # GET /images/1/edit
  def edit; end

  # POST /images
  # POST /images.json
  def create
    validate
    return redirect_to request.referer if session[:errors].present?

    update_image
    attach_if_new
    @image_blob.save
    redirect_to @parent
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
    session[:errors] = nil
    if image_params[:title].blank?
      session[:errors] = (session[:errors] || []).push(field: "title", message: "Title can't be blank")
    end
  end

  def attach_if_new
    if @parent.images.attachments.map(&:blob_id).exclude?(@image_blob.id)
      @parent.images.attach(@image_blob)
    end
  end
end
