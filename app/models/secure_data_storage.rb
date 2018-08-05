class SecureDataStorage < ApplicationRecord
  # virtual attributes
  attr_accessor :audience

  validates_uniqueness_of :token

  def initialize(attriubtes = {})
    super
    # do NOT use the default assign method
    self[:token] = SecureRandom.base58(32)
    self.document = Faker::Internet.password(6, 12, true, true)
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

  def self.seed!
    [Random.rand(2112), 765].max.times { try(:create!) }
  end

  def self.rand(audience)
    return self.new unless audience && audience[:aud]

    # number of available records
    @count ||= count
    # automatically generate fake entries, if the table is empty
    @count = seed! unless @count > 0
    # safety net if table is cleared, but not re-created
    #     id is hidden to the outside world, therefore the raw data has to be used
    @first ||= first[:id]
    begin
      retries ||= 0
      sds = find(Random.rand(@count) + @first)
      sds.audience = audience
      sds
    rescue ActiveRecord::RecordNotFound
      # normally there are no gaps in the ids - therefore it is save to just retry
      retry if (retries += 1) < 10
    end
  end
end
