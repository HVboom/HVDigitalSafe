require 'jwt'

module HVCrypto
  class JWT
    KEY = Rails.application.secrets.hmac_key
    API_KEY_AUD = Rails.application.secrets.api_key_aud
    ALGORITHM = 'HS512'
    ISSUER = Rails.application.class.name.deconstantize
    AUDIENCE = Rails.application.secrets.audience
    PATTERN = %r{[a-zA-Z0-9\-_]+?\.[a-zA-Z0-9\-_]+?\.([a-zA-Z0-9\-_]+)?}

    # Encodes and signs JWT payload
    def self.encode(data, claims = {})
      payload = {}
      payload[:data] = data
      payload.merge!(claims)
      payload.reverse_merge!(default_claims)
      ::JWT.encode(payload, KEY, ALGORITHM)
    end

    # Decodes the JWT token with the signed secret
    def self.decode(token, claims = {})
      begin
        # Add iss to the validation to check if the token has been manipulated
        payload = ::JWT.decode(token, KEY, true, decode_header.merge(claims))
        payload[0].with_indifferent_access[:data]
      rescue ::JWT::InvalidIssuerError, ::JWT::InvalidAudError, ::JWT::DecodeError
        Rails.logger.error '!!! You are under attack!'
        unless @usage
          Rails.logger.warn %q{
            Maybe your setup is not completed.
            Please either setup the secret key _Rails.application.secrets.audience_ or
            provide the _aud_ claim to the _encode_ / _decode_ calls
          }
          @usage = true
        end
        # slow down attacks
        sleep(Random.rand(3))
        nil
      end
    end

    # Decodes the JWT token with the API key secret
    def self.decode_api_key(token, claims = {})
      return nil unless token

      claims.reverse_merge!({aud: API_KEY_AUD})
      self.decode(token, claims)
    end

    # Default options to be encoded in the token
    def self.default_claims
      {
        iss: ISSUER,
        # If the AUDIENCE is not set - ensure, that all generated tokens
        # are *NOT* valid. Only if the _aud_ claim is provided it will work.
        aud: AUDIENCE || SecureRandom.base58(32)
      }
    end

    # Decode verification option
    def self.decode_header
      {
        verify_iss: true,
        verify_aud: true,
        algorithm: ALGORITHM
      }.reverse_merge!(default_claims)
    end
  end
end
