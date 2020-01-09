class FileUploadError < StandardError
  def initialize(error_message)
    @error_message = error_message
    super(@error_message)
  end

  def message
    "File Upload Error: #{@error_message}"
  end
end
