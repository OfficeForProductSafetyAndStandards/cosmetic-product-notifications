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
    initialize_file_attachment
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
    @image_blob = load_file_attachment
  end

  def validate
    @errors = ActiveModel::Errors.new(ActiveStorage::Blob.new)
    if file_params[:title].blank? && step != :upload
      @errors.add(:base, :title_not_implemented, message: "Title can't be blank")
    end
    if file_params[:file].blank? && step == :upload
      @errors.add(:base, :file_not_implemented, message: "File can't be blank")
    end
  end
end
