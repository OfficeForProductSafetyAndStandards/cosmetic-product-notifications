class UploadNanomaterialsPdfsJob < UploadNanomaterialsPdfsAbstractJob
  FILE_NAME = "NanomaterialsPDFs.zip".freeze
  TMP_DIR   = "tmp/nanomaterials_pdfs".freeze

private

  def nanomaterial_notifications_to_download
    NanomaterialNotification.submitted
  end
end
