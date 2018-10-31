class ImagesController < ApplicationController
  include ImagesHelper

  before_action :set_parent
  before_action :set_image, only: %i[edit create destroy]

  # GET /images/1/edit
  def edit; end

  # POST /images
  # POST /images.json
  def create
    validate
    if session[:errors].present?
      redirect_to request.referer
    else
      update_image
      @image.blob.save
      redirect_to @parent
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.purge_later
    redirect_to @parent
  end

private
  def set_image
    if @parent.present? && params[:id].present?
      @image = @parent.images.find(params[:id])
      session[:image_id] = @image&.id
    elsif session[:image_id]
      @image = @parent.images.find(session[:image_id])
    else
      create_image
    end
  end
end
