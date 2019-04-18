module Shared
  module Web
    module Concerns
      module DocumentUploadConcern
        extend ActiveSupport::Concern
        included do

          def self.add_document_validation(key, required, context)
            @document_validation_keys ||= []
            @document_validation_keys << [key, required, context] unless @document_validation_keys.include? [key, required, context]
          end

          def self.get_document_validation
            @document_validation_keys
          end

          def self.validate_upload_document(key, required, context=nil)
            attribute key unless self.respond_to? key
            add_document_validation(key, required, context)
            validate on: context do
              upload_documents(key, context)
            end
          end
        end

        def upload_documents(key, context)
          required = []
          self.class.get_document_validation.each do |validation_key, validation_required, validation_context|
            if validation_key == key && validation_context == context
              required.concat(validation_required)
            end
          end

          validate_document(key, required, context)
        end

        def validate_document(key, required, context)
          document_model = self.send(key)
          return unless document_model

          document_model.required_fields = required
          document_model.validate(context)
          merge_errors_with_key! document_model.errors, key
        end

        def merge_errors_with_key!(other_errors, key)
          other_errors_details = other_errors.details.map do |error_key, error_list|
            ["#{key}_#{error_key}".to_sym, error_list]
          end
          other_errors_messages = other_errors.messages.map do |error_key, messages|
            p ["#{key}_#{error_key}".to_sym, messages]
          end

          errors.messages.merge!(other_errors_messages.to_h) { |_, ary1, ary2| ary1 + ary2 }
          errors.details.merge!(other_errors_details.to_h) { |_, ary1, ary2| ary1 + ary2 }
        end
      end
    end
  end
end
