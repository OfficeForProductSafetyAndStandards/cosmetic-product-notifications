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
    associated_images_path(parent) + "/new/new"
  end

  def edit_associated_image_path(parent, image)
    associated_image_path(parent, image) + "/edit"
  end

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def save_image
    update_image
    images = @parent.images.attach(@image_blob)
    images.last.blob.save
    redirect_to @parent
  end

  def update_image
    @image_blob.metadata.update(image_params)
    @image_blob.metadata["updated"] = Time.current
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    return {} if params[:image].blank?

    params.require(:image).permit(:file, :title, :description)
  end
end
