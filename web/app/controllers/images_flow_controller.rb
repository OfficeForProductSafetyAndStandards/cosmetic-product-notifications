class ImagesFlowController < ApplicationController
  include ImagesHelper
  include Wicked::Wizard
  steps :upload, :metadata

  before_action :set_parent
  before_action :set_image, only: %i[show update]

  # GET /images/1
  # GET /images/1.json
  def show;
    render_wizard
  end

  # GET /images/new
  def new;
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    validate
    return render step if session[:errors].present?

    redirect_to next_wizard_path if step == :upload
  end

private

  def set_image
    if session[:image_blob_id]
      @image_blob = ActiveStorage::Blob.find_by(id: session[:image_blob_id])
    else
      create_image
    end
  end

  def validate
    session[:errors] = nil
    if image_params[:title].blank? && step != :upload
      session[:errors] = (session[:errors] || []).push(field: "title", message: "Title can't be blank")
    end
  end
end
