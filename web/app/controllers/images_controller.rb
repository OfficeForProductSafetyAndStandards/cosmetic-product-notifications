class ImagesController < ApplicationController
  include ImagesHelper

  before_action :set_parent
  before_action :set_image, only: %i[edit update create destroy]

  # POST /images
  # POST /images.json
  def create
    validate
    return redirect_to request.referer if @errors.present?

    save_image
  end

  # GET /images/1/edit
  def edit; end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    validate
    return render :edit if @errors.present?

    update_image
    redirect_to @parent
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    AuditActivity::Image::Destroy.from(@image, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

private

  def set_image
    if params[:id].present?
      @image = @parent.images.find(params[:id])
      @image_blob = @image.blob
    end
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if image_params[:title].blank?
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
  end

  def update_image
    @previous_data = {
      title: @image.metadata[:title],
      description: @image.metadata[:description]
    }
    update_image_details
    AuditActivity::Image::Update.from(@image, @parent, @previous_data) if @parent.class == Investigation
    @image_blob.save
  end
end
