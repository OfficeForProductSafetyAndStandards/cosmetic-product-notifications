require "zlib"

Rails.application.config.cpnp_static_file_names = %w[categories exposureConditions exposureRoute frameFormulation questions units].freeze

Rails.application.config.cpnp_static_file_hashes = Hash[Rails.application.config.cpnp_static_file_names.map do |filename|
  file_content = File.read(Rails.root.join("app", "assets", "files", "cpnp", filename + ".xml"))
  file_hash = Zlib.crc32(file_content)
  [filename, file_hash]
end]
