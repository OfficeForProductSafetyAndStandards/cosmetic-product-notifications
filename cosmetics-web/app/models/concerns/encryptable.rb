# Allows models to define attributes that will be encrypted.
#
# Usage EG: "attr_encrypted :secret" will encrypt values given to
# 'secret = "value"' into 'encrypted_secret'.
#
# Ideally the class will be an ActiveRecord class containing 'encrypted_secret'
# (not 'secret') as table field.
# Encryptable will define '#secret' and '#secret=' instance methods, so the
# value can be set to and retrieved from the encrypted db field.
module Encryptable
  extend ActiveSupport::Concern

  # Encrypt and Decrypt values using Rails ActiveSupport::MessageEncryptor.
  # Internally uses OpenSSL defaulting to aes-256-gcm cipher.
  # Each value is salted with a different salt to enforce uniqueness and avoid
  # rainbow table attacks.
  class Encryptor
    # Ensure to use the same cipher in our service even if a new Rails version
    # brings a different default cipher.
    # If we rely on whatever Rails considers the default and this changes in a
    # future Rails version, we wouldn't be able to decipher encrypted data prior
    # to the Rails upgrade.
    CIPHER = "aes-256-gcm".freeze
    LEN = ActiveSupport::MessageEncryptor.key_len(CIPHER)
    SECRET = Rails.application.secrets.secret_key_base

    def self.encrypt(value)
      salt = SecureRandom.hex(LEN)
      encrypted = encryptor(salt).encrypt_and_sign(value)
      # Individual salt is needed to decrypt the value
      "#{salt}$$#{encrypted}"
    end

    def self.decrypt(value)
      salt, data = value.split "$$"

      encryptor(salt).decrypt_and_verify(data)
    end

    def self.encryptor(salt)
      key = ActiveSupport::KeyGenerator.new(SECRET, cipher: CIPHER).generate_key(salt, LEN)
      ActiveSupport::MessageEncryptor.new(key)
    end

    private_class_method :encryptor
  end

  class_methods do
    def attr_encrypted(*attributes)
      attributes.each do |attribute|
        # Defines setter to enctrypt value and store it in encrypted field.
        # Eg: For an instance of a class including 'attr_encrypted :secret'
        #   'instance.secret = value" would store 'encrypted_value' into
        #   'instance.encrypted_secret'
        define_method("#{attribute}=".to_sym) do |value|
          encrypted_value = value.present? ? Encryptor.encrypt(value) : nil
          public_send("encrypted_#{attribute}=".to_sym, encrypted_value)
        end

        # Defines getter to decrypt and return value that is stored in encrypted field.
        # Eg: For an instance of a class including 'attr_encrypted :secret'
        #   'instance.secret' would return decrypted 'value' stored as
        #   'salt$$encrypted_value' in 'instance.encrypted_secret'
        define_method(attribute) do
          encrypted_value = public_send("encrypted_#{attribute}".to_sym)
          Encryptor.decrypt(encrypted_value) if encrypted_value.present?
        end
      end
    end
  end
end
