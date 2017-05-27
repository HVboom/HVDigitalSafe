class SecureDataStorage < ApplicationRecord
  validates_uniqueness_of :token

  def initialize(attriubtes = {})
    super
    # do NOT use the default assign method
    self[:token] = SecureRandom.base58(32)
    self.document = Faker::Internet.password(6, 12, true, true)
    # self.token = 'Token_' + Random.rand(1_000_000_000).to_s
    # self.document = Faker::Name.last_name
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
    HVCrypto::JWT.encode(self[:token])
  end

  # JWT ensures that nobody can temper the tokens
  def token=(token)
    self[:token] = HVCrypto::JWT.decode(token)
  end

  def self.seed!
    [Random.rand(2112), 765].max.times { self.create! }
  end

  def self.rand
    # number of available records
    @count ||= count
    # automatically generate fake entries, if the table is empty
    @count = seed! unless @count > 0
    # safety net if table is cleared, but not re-created
    #     id is hidden to the outside world, therefore the raw data has to be used
    @first ||= first[:id]
    begin
      retries ||= 0
      find(Random.rand(@count) + @first)
    rescue ActiveRecord::RecordNotFound
      # normally there are no gaps in the ids - therefore it is save to just retry
      retry if (retries += 1) < 10
    end
  end
end
