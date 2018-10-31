module FileConcern
  extend ActiveSupport::Concern
  def handle_file_attachment
    load_file_by_id if session[:file_id].present?
    save_file if file_params[:file].present?
  end

  def save_file
    documents = @correspondence.documents.attach(file_params[:file])
    @document = documents.last
    @document.blob.metadata["updated"] = Time.current
    @document.blob.save
    session[:file_id] = @document.blob_id
  end

  def load_file_by_id
    @document = ActiveStorage::Blob.find_by(id: session[:file_id])
    documents = @correspondence.documents.attach(@document)
    @document = documents.last
  end

  def file_params
    return {} if params[:correspondence].blank?

    params.require(:correspondence).permit(:file, :title, :description, :document_type)
  end
end
