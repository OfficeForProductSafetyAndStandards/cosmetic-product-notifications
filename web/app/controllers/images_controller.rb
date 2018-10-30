class ImagesController < ApplicationController
  include ImagesHelper
  include Wicked::Wizard
  steps :step_upload, :step_metadata
  skip_before_action :setup_wizard, only: %i[edit destroy]
  skip_before_action :verify_authenticity_token, only: :create

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
  def edit;
  end

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

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    validate
    return render step if session[:errors].present?

    update_image
    redirect_to next_wizard_path if step == :step_upload
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.purge_later
    redirect_to @parent
  end

  private

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def set_image
    if @parent.present? && is_number?(params[:id])
      @image = @parent.images.find(params[:id])
      session[:image_id] = @image&.id
    elsif session[:image_id]
      @image = @parent.images.find(session[:image_id])
    else
      create_image
    end
  end

  def is_number? string
    # Sadly Wizard uses id param as a means of distinguishing its steps
    # This means we need to make sure id is a number before we try to find an image by it
    return false if string.blank?

    true if Integer(string) rescue false
  end

  def create_image
    if image_params.present?
      @images = @parent.images.attach(image_params[:file])
      @image = @images.last
      session[:image_id] = @image.id
    end
  end

  def update_image
    @image.blob.metadata.update(image_params)
    @image.blob.metadata["updated"] = Time.current
  end

  def validate
    session[:errors] = nil
    if (image_params[:title].blank? && step != :step_upload)
      session[:errors] = (session[:errors] || []).push({field: "title", message: "Title can't be blank"})
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    return {} if params[:image].blank?

    params.require(:image).permit(:file, :title, :description)
  end
end
