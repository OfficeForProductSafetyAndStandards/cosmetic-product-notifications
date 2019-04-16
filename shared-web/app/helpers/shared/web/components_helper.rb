module Shared
  module Web
    module ComponentsHelper
      # Patterns for names and ids can be found in examples here: https://guides.rubyonrails.org/form_helpers.html
      def get_attribute_name(form, attribute)
        form.object_name.present? ? "#{form.object_name}[#{attribute}]" : attribute.to_s
      end

      def get_attribute_id_prefix(form, attribute)
        initial_name = form.object_name.present? ? "#{form.object_name}_#{attribute}" : attribute.to_s
        initial_name.gsub(/[\[\]_]+/, "_")
      end

      def get_subform_attribute_id_prefix(form, subform_key, attribute)
        initial_name = form.object_name.present? ? "#{form.object_name}_#{subform_key}_#{attribute}" : attribute.to_s
        initial_name.gsub(/[\[\]_]+/, "_")
      end
    end
  end
end
