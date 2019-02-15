module ErroneousNotificationFileHelper
  def get_error_message(upload_error)
    messages = {
        uploaded_file_not_a_zip: "Uploaded file is not a ZIP file",
        unzipped_files_not_xml: "Unzipped files are not XML files",
        unzipped_files_are_pdf: "Unzipped files are PDF files",
        file_flagged_as_virus: "Unzipped files contain a virus",
        file_size_too_big: "Uploaded file exceeds size limit",
        notification_validation_error: "Unknown error",
        notification_duplicated: "A notification for this file already exists",
        unknown_error: "Unknown error"
    }.stringify_keys
    messages[upload_error]
  end
end
