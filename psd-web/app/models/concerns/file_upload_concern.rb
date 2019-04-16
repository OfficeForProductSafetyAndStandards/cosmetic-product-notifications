module FileUploadConcern
  extend ActiveSupport::Concern

  # included do
  #   def self.add_upload_key(key, required)
  #     @upload_keys ||= []
  #     @upload_keys << [key, required] unless @upload_keys.include? [key, required]
  #   end
  #
  #   def self.get_upload_keys
  #     @upload_keys
  #   end
  #
  #   def self.enable_upload(key, required: true)
  #     self.class_eval do
  #       attribute "#{key}_file_id".to_sym
  #     end
  #
  #     after_initialize do
  #       self.class.add_upload_key(key, required)
  #     end
  #   end
  # end

private

  def file_id_symbol(key)
    "#{key}_file_id".to_sym
  end

  def get_file_id(key)
    self.send(file_id_symbol(key))
  end

  def set_file_id(key, value)
    self.send("#{key}_file_id=", value)
  end
end
