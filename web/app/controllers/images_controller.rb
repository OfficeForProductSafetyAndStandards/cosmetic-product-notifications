class ImagesController < ApplicationController
  include ImagesHelper
  include Wicked::Wizard
  steps :step_upload, :step_metadata
  skip_before_action :setup_wizard, only: :edit
  skip_before_action :verify_authenticity_token, :only => :create

  before_action :set_parent
  before_action :set_image, only: %i[show update edit create destroy]

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
  def show;
    render_wizard
  end

  # GET /images/new
  def new;
    session[:image_id] = nil
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET /images/1/edit
  def edit; end

  # POST /images
  # POST /images.json
  def create
    update_image
    @image.blob.save
    redirect_to @parent
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    create_image if step == :step_upload
    set_image if step == :step_metadata
    update_image
    @image.blob.save
    redirect_to next_wizard_path(image_id: @image.id) if step == :step_upload
    redirect_to @parent if step == :step_metadata || step == :edit_metadata
  end

  def soft_delete
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.purge_later
    respond_to do |format|
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
    @image = @parent.images.find(params[:id]) if @parent.present? && is_number?(params[:id])
    @image = @image || @parent.images.find(params[:image_id]) if @parent.present? && params[:image_id]
    @image = @image || @parent.images.find(session[:image_id]) if session[:image_id]
    session[:image_id] = @image&.id
    create_image if !@image
  end

  def is_number? string
    return false if string.blank?

    true if Integer(string) rescue false
  end

  def create_image
    if !image_params.blank?
      @images = @parent.images.attach(image_params[:file])
      @image = @images.last
      session[:image_id] = @image.id
    end
  end

  def update_image
    @image.blob.metadata.update(image_params)
    @image.blob.metadata["updated"] = Time.current
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    return {} if params[:image].blank?

    params.require(:image).permit(:file, :title, :description)
  end
end
