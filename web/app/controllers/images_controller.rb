class ImagesController < ApplicationController
  include ImagesHelper

  before_action :set_parent
  before_action :set_image, only: %i[show edit update destroy]
  before_action :create_image, only: %i[create]
  before_action :update_image, only: %i[update]

  helper_method :associated_image_path
  helper_method :associated_images_path
  helper_method :new_associated_image_path
  helper_method :edit_associated_image_path

  # GET /images
  # GET /images.json
  def index
    @images = @parent.images.attachments
  end

  # GET /images/1
  # GET /images/1.json
  def show; end

  # GET /images/new
  def new; end

  # GET /images/1/edit
  def edit; end

  # POST /images
  # POST /images.json
  def create
    respond_to do |format|
      if @image
        AuditActivity::Image::Add.from(@image, @parent) if @parent.class == Investigation
        format.html { redirect_to edit_associated_image_path(@parent, @image) }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.blob.save
        AuditActivity::Image::Update.from(@image, @parent, @previous_data) if @parent.class == Investigation
        format.html { redirect_to action: "index", notice: "Image was successfully saved." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.delete #note this is a soft delete to preserve the image for case history
    respond_to do |format|
      AuditActivity::Image::Destroy.from(@image, @parent) if @parent.class == Investigation
      format.html { redirect_to action: "index", notice: "Image was successfully deleted." }
      format.json { head :no_content }
    end
  end

private

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def set_image
    @image = @parent.images.find(params[:id]) if @parent.present?
  end

  def create_image
    @images = @parent.images.attach(image_params[:file])
    @image = @images.last
  end

  def update_image
    @previous_data = {
        title: @image.metadata[:title],
        description: @image.metadata[:description]
    }
    @image.blob.metadata.update(image_params)
    @image.blob.metadata["updated"] = Time.current
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:file, :title, :description)
  end
end
