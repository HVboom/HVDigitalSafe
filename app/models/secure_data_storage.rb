class SecureDataStorage < ApplicationRecord
  # virtual attributes
  attr_accessor :audience

  validates_uniqueness_of :token

  def initialize(attriubtes = {})
    super
    # do NOT use the default assign method
    self[:token] = SecureRandom.base58(32)
    self.document = Faker::Internet.password(min_length: 8, max_length: 20, mix_case: true, special_characters: true)
    # ensure, that faked data can never be decoded
    self.audience = {}
    self.audience[:aud] = SecureRandom.base58(32)
  end

  # use the token for the URLs
  def to_param
    token
  end

  # do not expose the technical identifier
  def id
    token
  end

  # expose JWT encoded tokens to the outside world
  def token
    HVCrypto::JWT.encode(self[:token], audience)
  end

  # JWT ensures that nobody can temper the tokens
  def token=(token)
    self[:token] = HVCrypto::JWT.decode(token, audience)
  end

  # obscure stored data
  def document
    HVCrypto::Synchron.decode(self[:document])
  end

  def document=(document)
    self[:document] = HVCrypto::Synchron.encode(document)
  end

  def self.number_of_seed_records
    [Random.rand(2112), 765].max
  end

  def self.seed!
    number_of_seed_records.times { try(:create!) }
  end

  def self.rand(audience)
    return self.new unless audience && audience[:aud]

    # FIXME: if seed! is never called, then the table is maybe empty
    sds = order("RANDOM()").first
    sds.audience = audience
    sds
  end
end
