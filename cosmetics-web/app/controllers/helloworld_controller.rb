class HelloworldController < ApplicationController
  def index
    TestJob.perform_later
    puts 'Testing!'
  end

  def send_email
    NotifyMailer.send_test_email('Recipient', 'user@example.com').deliver_later
  end

  def upload_file
    uploaded_io = params[:uploaded_file]
  
    blob = ActiveStorage::Blob.create_after_upload!(
      io: uploaded_io,
      filename: uploaded_io.original_filename,
      content_type: uploaded_io.content_type,
      metadata: nil
    )
    
    render json: { filelink: url_for(blob) }
  end
end
