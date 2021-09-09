class CommonPasswordValidator < ActiveModel::EachValidator
  COMMON_PASSWORDS_FILE = "app/assets/10-million-password-list-top-1000000.txt".freeze
  DEFAULT_ERROR = "Choose a less frequently used password".freeze

  def self.cache_common_passwords
    h = {}
    File.foreach(COMMON_PASSWORDS_FILE, chomp: true) do |common_password|
      h[common_password] = true
    end
    h
  end

  COMMON_PASSWORDS = cache_common_passwords

  def validate_each(record, attribute, value)
    if COMMON_PASSWORDS[value]
      record.errors.add(attribute, :invalid, message: (options[:message] || DEFAULT_ERROR))
    end
  end
end
