# UnusedCodeAlerting
# This module seems unused. Delete it if all methods are unused.
module FileHelper
  def get_filetype_extension(filetype)
    UnusedCodeAlerting.alert
    filetype_extensions[filetype]
  end

private

  def filetype_extensions
    {
      "application/pdf" => ".pdf",
      "application/rtf" => ".rtf",
      "text/plain" => ".txt",
    }
  end
end
