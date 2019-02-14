module Shared
  module Web
    module ComponentsHelper
      def get_me_here
        "get_me_here"
      end
      def get_attribute_name(form, attribute)
        form.object_name.present? ? "#{form.object_name}[#{attribute}]" : attribute.to_s
      end
      def get_attribute_id_prefix(form, attribute)
        form.object_name.present? ? "#{form.object_name}_#{attribute}" : attribute.to_s
      end
    end
  end
end
