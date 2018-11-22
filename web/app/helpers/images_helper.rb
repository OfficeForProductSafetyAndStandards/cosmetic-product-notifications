module ImagesHelper
  include FileConcern

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def audit_class
    AuditActivity::Image
  end

  def file_collection
    @parent.images
  end
end
