class ImagesFlowController < ApplicationController
  include ImagesHelper
  include Wicked::Wizard
  steps :upload, :metadata

  before_action :set_parent
  before_action :set_image, only: %i[show update]

  def show;
    render_wizard
  end

  def new;
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def update
    validate
    return render step if @errors.present?

    return redirect_to next_wizard_path if step != steps.last

    save_image
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
    @errors = nil
    if image_params[:title].blank? && step != :upload
      @errors = (@errors || []).push(field: "title", message: "Title can't be blank")
    end
  end
end
