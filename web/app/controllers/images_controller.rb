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
        create_audit_activity_for_add_image_to_investigation if @parent.class == Investigation
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
        create_audit_activity_for_update_image_in_investigation if @parent.class == Investigation
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
      create_audit_activity_for_destroy_image_in_investigation if @parent.class == Investigation
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

  def create_audit_activity_for_add_image_to_investigation
    title = @image.metadata[:title] || "Untitled image"
    activity = AddImageAuditActivity.create(
        description: @image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: @parent,
        title: title)
    activity.image.attach @image.blob
  end

  def create_audit_activity_for_update_image_in_investigation
    if @image.metadata[:title] != @previous_title
      title = "Updated: #{@image.metadata[:title] || "Untitled image"} (was: #{@previous_data[:title] || "Untitled image"})"
    elsif @image.metadata[:description] != @previous_data[:description]
      title = "Updated: Description for #{@image.metadata[:title]}"
    end
    activity = UpdateImageAuditActivity.create(
        description: @image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: @parent,
        title: title)
    activity.image.attach @image.blob
  end

  def create_audit_activity_for_destroy_image_in_investigation
    activity = DestroyImageAuditActivity.create(
        description: @image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: @parent,
        title: "Deleted: #{@image.metadata[:title]}")
    activity.image.attach @image.blob
  end
end
