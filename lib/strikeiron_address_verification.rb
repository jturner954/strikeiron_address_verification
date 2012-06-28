require 'strikeiron_address_verification/address'
module STRIKEIRON_ADDRESS_VERIFICATION
  class << self
    attr_accessor :username
    attr_accessor :password
    attr_accessor :url
    attr_accessor :timeout
    attr_accessor :open_timeout
  end
  def self.configure(&block)
    yield(self)
  end
end
