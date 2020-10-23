module FileHelper
  def get_filetype_extension(filetype)
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
