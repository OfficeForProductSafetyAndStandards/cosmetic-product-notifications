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

  def edit_associated_image_path(parent, image)
    associated_image_path(parent, image) + "/edit"
  end

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
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
    if image_params[:title].blank? && step != :upload
      session[:errors] = (session[:errors] || []).push(field: "title", message: "Title can't be blank")
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    return {} if params[:image].blank?

    params.require(:image).permit(:file, :title, :description)
  end
end
