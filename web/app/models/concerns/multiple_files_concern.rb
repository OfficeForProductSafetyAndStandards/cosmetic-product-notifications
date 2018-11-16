module MultipleFilesConcern
  extend ActiveSupport::Concern
  include FileConcern

  module ClassMethods
    attr_reader :attachment_categories

    private

    def set_attachment_categories filenames
      @attachment_categories = filenames
    end
  end

  def attachment_categories
    self.class.attachment_categories
  end

  def initialize_file_attachments
    attachment_categories.each { |category| session[category] = nil }
  end

  def load_file_attachments
    attachment_categories.map {|category| load_file_attachment category}
  end

  def attach_files_to_list(documents, files = {})
    files.each do |attachment_category, file|
      attach_file_to_list(file, attachment_category, documents)
    end
  end

  def validate_blob_sizes(errors, files ={})
    files.each do |attachment_category, file|
      validate_blob_size(file, errors, attachment_category)
    end
  end
end
