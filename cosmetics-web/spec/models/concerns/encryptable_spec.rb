require "rails_helper"

RSpec.describe Encryptable, type: :model do
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Encryptable

      attribute :encrypted_secret # In an ActiveRecord class this will be a db field.
      attr_encrypted :secret

      def self.name
        "DummyClass"
      end
    end
  end

  let(:dummy) { dummy_class.new }

  describe "defined setter for encryptable attribute" do
    it "encrypts the attr value in 'encrypted_attr'" do
      expect { dummy.secret = "foobar" }.to change(dummy, :encrypted_secret).from(nil)
    end

    it "sets the encrypted value to nil when given an empty value" do
      dummy.secret = "foobar"
      expect { dummy.secret = "" }.to change(dummy, :encrypted_secret).to(nil)
    end

    it "sets the encrypted value to nil when given a nil value" do
      dummy.secret = "foobar"
      expect { dummy.secret = nil }.to change(dummy, :encrypted_secret).to(nil)
    end
  end

  describe "defined getter for encryptable attribute" do
    it "returns the decrypted value" do
      dummy.encrypted_secret = dummy_class::Encryptor.encrypt("foobar")
      expect(dummy.secret).to eq("foobar")
    end

    it "returns nil when encrypted value is not set" do
      dummy.encrypted_secret = nil
      expect(dummy.secret).to be_nil
    end

    it "returns nil when encrypted value is empty" do
      dummy.encrypted_secret = ""
      expect(dummy.secret).to be_nil
    end
  end

  describe "Encryptor" do
    let(:encryptor) { dummy_class::Encryptor }

    describe "#encrypt" do
      it "generates an output different from the input" do
        encrypted_value = encryptor.encrypt("foobar")
        expect(encrypted_value).not_to eq("foobar")
      end

      it "prepends encrypted value with a salt" do
        encrypted_value = encryptor.encrypt("foobar")
        expect(encrypted_value.split("$$").size).to eq 2
        # Key length for 'aes-256-gcm': 32 bytes. In hexadecimal: 2 * 32 = 64
        expect(encrypted_value.split("$$").first.size).to eq 64
      end

      it "each run for the same value generates a different encrypted output" do
        first_output = encryptor.encrypt("foobar")
        expect(encryptor.encrypt("foobar")).not_to eq first_output
      end
    end

    describe "#decrypt" do
      it "reverses the encryption to return the original value" do
        encrypted_value = encryptor.encrypt("foobar")
        expect(encryptor.decrypt(encrypted_value)).to eq("foobar")
      end

      it "fails to decrypt when missing salt" do
        encrypted_missing_salt = encryptor.encrypt("foobar").split("$$").last
        expect { encryptor.decrypt(encrypted_missing_salt) }
          .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it "fails to decrypt when salt is different than used to encrypt" do
        encrypted_missing_salt = encryptor.encrypt("foobar").split("$$").last
        new_salt = SecureRandom.hex(encryptor::LEN)
        encrypted_value = "#{new_salt}$$#{encrypted_missing_salt}"
        expect { encryptor.decrypt(encrypted_value) }
          .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end
end
