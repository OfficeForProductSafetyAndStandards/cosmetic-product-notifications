module ImagesHelper
  include FileConcern

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
    image = attach_file_to_list(@image_blob, @parent.images)
    AuditActivity::Image::Add.from(image, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

  def get_file_params_key
    :image
  end
end
