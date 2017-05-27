require 'jwt'

module HVCrypto
  class JWT
    ALGORITHM = 'HS512'

    # Encodes and signs JWT payload
    def self.encode(data, claims = {})
      payload = {}
      payload[:data] = data
      payload.reverse_merge!(claims)
      payload.reverse_merge!(default_claims)
      ::JWT.encode(payload, Rails.application.secrets.hmac_key, ALGORITHM)
    end

    # Decodes the JWT with the signed secret
    def self.decode(token, claims = {})
      begin
        # Add iss to the validation to check if the token has been manipulated
        payload = ::JWT.decode(token, Rails.application.secrets.hmac_key, true, decode_header.merge(claims))
        # Rails.logger.debug "Payload decoded: #{payload.inspect}"
        payload[0].with_indifferent_access[:data]
      rescue ::JWT::InvalidIssuerError, ::JWT::InvalidAudError
        nil
      end
    end

    # Default options to be encoded in the token
    def self.default_claims
      {
        iss: Rails.application.class.name.deconstantize,
        aud: 'HVKeyGuard'
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
