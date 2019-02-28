require 'zlib'

module CpnpStaticFiles
  def is_static_file(file)
    Rails.application.config.cpnp_static_file_names.include? get_file_name(file)
  end

  def static_file_contents_differs(file)
    file_hash = Zlib::crc32(file.get_input_stream.read)
    expected_hash = Rails.application.config.cpnp_static_file_hashes[get_file_name(file)]
    file_hash != expected_hash
  end

  def get_file_name(file)
    file.name.split("_").first
  end
end
