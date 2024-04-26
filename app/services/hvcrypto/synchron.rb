module HVCrypto
  class Synchron
    KEY = ActiveSupport::KeyGenerator.new(Rails.application.credentials[:message_key]).
      generate_key(Rails.application.credentials[:secret_key_base], 32)
    ENCRYPTOR = ActiveSupport::MessageEncryptor.new(KEY)

    # Encodes and signs with MessageEncryptor
    def self.encode(data)
      ENCRYPTOR.encrypt_and_sign(data)
    end

    # Decodes and signs with MessageEncryptor
    def self.decode(data)
      ENCRYPTOR.decrypt_and_verify(data)
    end
  end
end
