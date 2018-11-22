module ImagesHelper
  include FileConcern

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def save_file
    @file_blob.metadata.update(get_attachment_metadata_params(:file))
    @file_blob.metadata["updated"] = Time.current
    attach_blobs_to_list(@file_blob, file_collection)
    audit_class::Add.from(@file_blob, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

  def audit_class
    AuditActivity::Image
  end

  def file_collection
    @parent.images
  end
end
