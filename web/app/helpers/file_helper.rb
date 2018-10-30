module FileHelper
  def handle_file_attachment
    load_file_by_id if session[:file_id].present?
    save_file if correspondence_params[:file].present?
  end

  def save_file
    documents = @correspondence.documents.attach(correspondence_params[:file])
    @document = documents.last
    @document.blob.save
    session[:file_id] = @document.blob_id
  end

  def load_file_by_id
    @document = ActiveStorage::Blob.find_by(id: session[:file_id])
    @correspondence.documents.attach(@document)
  end
end
