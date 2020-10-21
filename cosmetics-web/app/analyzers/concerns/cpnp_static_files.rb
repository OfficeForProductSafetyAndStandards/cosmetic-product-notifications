require "zlib"

module CpnpStaticFiles
  def static_file?(file)
    Rails.application.config.cpnp_static_file_names.include? get_file_name_prefix(file)
  end

  def file_contents_differs?(file)
    file_hash = Zlib.crc32(file.get_input_stream.read)
    expected_hash = Rails.application.config.cpnp_static_file_hashes[get_file_name_prefix(file)]
    file_hash != expected_hash
  end

private

  def get_file_name_prefix(file)
    file.name.split("_").first
  end
end
