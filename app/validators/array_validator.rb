class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    Array(values).each do |value|
      options.each do |key, args|
        validator_options = { attributes: attribute }
        validator_options.merge!(args) if args.is_a?(Hash)

        next if value.nil? && validator_options[:allow_nil]
        next if value.blank? && validator_options[:allow_blank]

        validator_class = validator_class(key)
        validator = validator_class.new(validator_options)
        validator.validate_each(record, attribute, value)
      end
    end
  end

private

  def validator_class(validator_name)
    class_name = "#{validator_name.to_s.camelize}Validator"
    begin
      class_name.constantize
    rescue NameError
      "ActiveModel::Validations::#{class_name}".constantize
    end
  end
end
