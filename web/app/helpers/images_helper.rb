module ImagesHelper
  def associated_images_path(parent)
    polymorphic_path([parent, :images])
  end

  def associated_image_path(parent, image)
    associated_images_path(parent) + "/" + image.id.to_s
  end

  def new_associated_image_path(parent)
    associated_images_path(parent) + "/new"
  end

  def new_image_flow_path(parent)
    associated_images_path(parent) + "/image_flow/new"
  end

  def edit_associated_image_path(parent, image)
    associated_image_path(parent, image) + "/edit"
  end

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
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

  def update_image
    @image_blob.metadata.update(image_params)
    @image_blob.metadata["updated"] = Time.current
  end

  def save_image
    update_image
    @parent.images.attach(@image_blob)
    @image_blob.save
    redirect_to @parent
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    return {} if params[:image].blank?

    params.require(:image).permit(:file, :title, :description)
  end

  def clear_session
    session[:image_blob_id] = nil
  end
end
