class UploadNanomaterialsPdfsInLastThreeMonthsJob < UploadNanomaterialsPdfsAbstractJob
  FILE_NAME = "NanomaterialsPDFsInLastThreeMonths.zip".freeze
  TMP_DIR   = "tmp/nanomaterials_pdfs_in_last_three_months".freeze

private

  def nanomaterial_notifications_to_download
    NanomaterialNotification.where("submitted_at > '#{3.months.ago.beginning_of_month.to_date}'")
  end
end
