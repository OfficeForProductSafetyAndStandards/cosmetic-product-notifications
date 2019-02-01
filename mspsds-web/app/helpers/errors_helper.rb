module ErrorsHelper
  def file_validation_errors?(errors)
    errors.details[:base].any? { |error| error.value? :file_too_large }
  end
end
