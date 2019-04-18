module Shared
  module Web
    class Document
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attr_accessor :file
      attr_accessor :title, :description, :document_type, :filename, :required_fields

      validate :validate_blob_size
      validate :has_required_fields

      MAX_FILE_BYTE_SIZE = 100.megabytes

      # file_object must be either an instance of ActiveStorage::Blob or nil
      # Use cases for file_object being nil are
      # 1. Validating presence of a file in this model, rather than in controller
      # 2. Facilitating optional file inputs without added complexity in controller
      def initialize(file_object)
        check_arguments(file_object)

        @required_fields = []
        return unless file_object

        @file = file_object
        @filename = file_object.filename
        return unless file_object.metadata

        @title = file_object.metadata["title"]
        @description = file_object.metadata["description"]
        @document_type = file_object.metadata["document_type"]
      end

      # Rubocop crashes if we name this method 'update'
      # It's a recent issue tracked here: https://github.com/rubocop-hq/rubocop/issues/6888
      # We can change it to update after it's fixed
      def update_file(params)
        @title = params[:title]
        @description = params[:description]

        if valid?
          return unless @file

          update_blob_metadata(@file, params)
          @file.save
          true
        end
      end

      def purge_file
        return if @file.blank?

        @file.purge
      end

      def attach_blob_to_list(documents)
        return if @file.blank?

        attachments = documents.attach(@file)
        attachment = attachments.last
        attachment.blob.save
      end

      def detach_blob_from_list(documents)
        return if @file.blank?

        attachment = documents.find { |doc| doc.blob_id == @file.id }
        attachment.destroy
      end

      def attach_blob_to_attachment_slot(attachment_slot)
        return if @file.blank?

        attachment_slot.detach if attachment_slot.attached?
        attachment_slot.attach(@file)
        attachment_slot.blob.save
      end

    private

      def check_arguments(file_object)
        if file_object && !file_object.is_a?(ActiveStorage::Blob)
          raise "Document can only be initialized with an active storage blob or nil"
        end
      end

      def update_blob_metadata(blob, metadata)
        blob.metadata.update(metadata)
        blob.metadata["updated"] = Time.current
      end

      def validate_blob_size
        return unless @file && (@file.byte_size > MAX_FILE_BYTE_SIZE)

        errors.add(:file, :file_too_large, message: "File is too big, allowed size is #{MAX_FILE_BYTE_SIZE / 1.megabyte} MB")
      end

      def has_required_fields
        @required_fields.each do |field_key|
          errors.add(field_key, :blank) if self.send(field_key).blank?
        end
      end
    end
  end
end
