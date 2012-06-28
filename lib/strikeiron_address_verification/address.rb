require 'rest-client'
require 'crack'
require 'active_support/core_ext/string'
#require 'active_support/core_ext/hash'
module STRIKEIRON_ADDRESS_VERIFICATION
  class Address
    attr_accessor :username, :password, :url, :timeout, :open_timeout
    attr_accessor :street_address, :street_address_2, :city, :state, :zip_code, :status, :status_msg, :error, :request, :response
    def initialize
      @username = STRIKEIRON_ADDRESS_VERIFICATION.username
      @password = STRIKEIRON_ADDRESS_VERIFICATION.password
      @url = STRIKEIRON_ADDRESS_VERIFICATION.url
      @timeout = STRIKEIRON_ADDRESS_VERIFICATION.timeout
      @open_timeout = STRIKEIRON_ADDRESS_VERIFICATION.open_timeout
      @street_address = @street_address_2 = @city = @state = @zip_code = @status = @status_msg = @request = @response = ''
    end

    def verify(args)
      @street_address = args[:street_address] if args[:street_address]
      @street_address_2 = args[:street_address_2] if args[:street_address_2]
      @city = args[:city] if args[:city]
      @state = args[:state] if args[:state]
      @zip_code = args[:zip_code] if args[:zip_code]
      process
    end

    def is_valid?
      @is_valid || @error.present?
    end

    private

    def process
      begin
        fire_request
        hashed_response = Crack::XML.parse(@response)['WebServiceResponse']['NorthAmericanAddressVerificationResponse']['NorthAmericanAddressVerificationResult']
        @status = hashed_response['ServiceStatus']['StatusNbr']
        @status_msg = hashed_response['ServiceStatus']['StatusDescription']
        @is_valid = is_address_valid?
      rescue Exception => e
        @error = e.message
      end
    end

    def fire_request
      # open_timeout: amount of time to open connection
      # timeout: amount of time to wait for response
      @response = RestClient::Request.execute(:method => :post, :url => STRIKEIRON_ADDRESS_VERIFICATION.url, :payload => prepare_payload, :headers => {}, :timeout => STRIKEIRON_ADDRESS_VERIFICATION.timeout, :open_timeout => STRIKEIRON_ADDRESS_VERIFICATION.open_timeout)
    end

    def is_address_valid?
      @status != 304 && @status != 402
    end

    def prepare_payload
      payload = {}
      payload[:'LicenseInfo.RegisteredUser.UserID'] = STRIKEIRON_ADDRESS_VERIFICATION.username
      payload[:'LicenseInfo.RegisteredUser.Password'] = STRIKEIRON_ADDRESS_VERIFICATION.password
      payload[:'NorthAmericanAddressVerification.AddressLine1'] = @street_address
      payload[:'NorthAmericanAddressVerification.AddressLine2'] = @street_address_2
      payload[:'NorthAmericanAddressVerification.CityStateOrProvinceZIPOrPostalCode'] = "#{@city} #{@state} #{@zip_code}"
      payload[:'NorthAmericanAddressVerification.Country'] = 'US'
      payload[:'NorthAmericanAddressVerification.Casing'] = 'PROPER'
      payload
    end
  end

end

# == Schema Information
#
# Table name: address_verifications
#
#  id               :integer         not null, primary key
#  order_id         :integer
#  street_address   :string(255)     default(""), not null
#  street_address_2 :string(255)     default("")
#  city             :string(255)     default(""), not null
#  state            :string(255)     default(""), not null
#  zip_code         :string(255)     default(""), not null
#  is_valid         :boolean         default(FALSE), not null
#  status           :integer
#  status_msg       :string(255)
#  error            :string(255)
#  response         :text
#  created_at       :datetime
#  updated_at       :datetime
#

