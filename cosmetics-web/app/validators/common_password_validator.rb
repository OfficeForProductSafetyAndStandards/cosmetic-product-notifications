class CommonPasswordValidator < ActiveModel::EachValidator
  COMMON_PASSWORDS_FILE = "app/assets/10-million-password-list-top-1000000.txt".freeze
  DEFAULT_ERROR = "Choose a less frequently used password".freeze

  def validate_each(record, attribute, value)
    File.foreach(COMMON_PASSWORDS_FILE, chomp: true) do |common_password|
      if common_password == value
        record.errors.add(attribute, :invalid, message: (options[:message] || DEFAULT_ERROR))
        break
      end
    end
  end
end
