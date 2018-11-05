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

  def create_image
    if image_params.present?
      @image_blob = ActiveStorage::Blob.create_after_upload!(
        io: image_params[:file],
        filename: image_params[:file].original_filename,
        content_type: image_params[:file].content_type
      )
      session[:image_blob_id] = @image_blob.id
      @image_blob.analyze_later
    end
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if image_params[:title].blank? && step != :upload
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    if image_params[:file].blank? && step == :upload
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
  end

  def clear_session
    session[:image_blob_id] = nil
  end
end
