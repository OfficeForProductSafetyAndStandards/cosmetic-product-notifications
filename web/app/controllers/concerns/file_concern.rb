module FileConcern
  extend ActiveSupport::Concern

  def load_file_attachment
    load_file_by_id if session[:file_id].present?
    save_and_store_blob if file_params[:file].present?
  end

  def save_and_store_blob
    @document = ActiveStorage::Blob.create_after_upload!(
      io: file_params[:file],
      filename: file_params[:file].original_filename,
      content_type: file_params[:file].content_type
    )
    session[:file_id] = @document.id
    @document.analyze_later
  end

  def load_file_by_id
    @document = ActiveStorage::Blob.find_by(id: session[:file_id])
  end

  def handle_file_attachment
    if @document
      @document.metadata.update(file_params)
      @document.metadata["updated"] = Time.current
      documents = @correspondence.documents.attach(@document)
      document_attachment = documents.last
      document_attachment.blob.save
    end
  end

  def file_params
    return {} if params[:correspondence].blank?

    params.require(:correspondence).permit(:file, :title, :description, :document_type)
  end
end
