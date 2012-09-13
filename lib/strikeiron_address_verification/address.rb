require 'rest-client'
require 'crack'
require 'active_support/core_ext/string'
#require 'active_support/core_ext/hash'
module STRIKEIRON_ADDRESS_VERIFICATION
  class Address
    attr_accessor :username, :password, :url, :timeout, :open_timeout
    attr_accessor :street_address, :street_address_2, :city, :state, :zip_code, :is_valid, :status, :status_msg, :error, :request, :response, :record_type
    def initialize(args={})
      @username = STRIKEIRON_ADDRESS_VERIFICATION.username
      @password = STRIKEIRON_ADDRESS_VERIFICATION.password
      @url = STRIKEIRON_ADDRESS_VERIFICATION.url
      @timeout = STRIKEIRON_ADDRESS_VERIFICATION.timeout.to_i
      @open_timeout = STRIKEIRON_ADDRESS_VERIFICATION.open_timeout.to_i
      @street_address = @street_address_2 = @city = @state = @zip_code = @status = @status_msg = @request = @response = @record_type = @error = ''
      @is_valid = false
      @street_address = args[:street_address] if args[:street_address]
      @street_address_2 = args[:street_address_2] if args[:street_address_2]
      @city = args[:city] if args[:city]
      @state = args[:state] if args[:state]
      @zip_code = args[:zip_code] if args[:zip_code]
      process
    end

    private

    def process
      begin
        fire_request
        hashed_response = Crack::XML.parse(@response)['WebServiceResponse']['NorthAmericanAddressVerificationResponse']['NorthAmericanAddressVerificationResult']
        @status = hashed_response['ServiceStatus']['StatusNbr']
        @status_msg = hashed_response['ServiceStatus']['StatusDescription']
        @is_valid = is_address_valid?
        @record_type = hashed_response['ServiceResult']['USAddress']['RecordType'] if hashed_response &&  hashed_response['ServiceResult'] && hashed_response['ServiceResult']['USAddress'] && hashed_response['ServiceResult']['USAddress']['RecordType']
      rescue Exception => e
        @error = e.message
      end
      #puts "#{@status.class} #{is_address_valid?}  - address: #{@street_address}"
    end

    def fire_request
      # open_timeout: amount of time to open connection
      # timeout: amount of time to wait for response
      @response = RestClient::Request.execute(:method => :post, :url => @url, :payload => prepare_payload, :headers => {}, :timeout => @timeout, :open_timeout => @open_timeout)
    end

    def is_address_valid?
      @status != '304' && @status != '402'
    end

    def prepare_payload
      payload = {}
      payload[:'LicenseInfo.RegisteredUser.UserID'] = @username
      payload[:'LicenseInfo.RegisteredUser.Password'] = @password
      payload[:'NorthAmericanAddressVerification.AddressLine1'] = @street_address
      payload[:'NorthAmericanAddressVerification.AddressLine2'] = @street_address_2
      payload[:'NorthAmericanAddressVerification.CityStateOrProvinceZIPOrPostalCode'] = "#{@city} #{@state} #{@zip_code}"
      payload[:'NorthAmericanAddressVerification.Country'] = 'US'
      payload[:'NorthAmericanAddressVerification.Casing'] = 'PROPER'
      payload
    end
  end

end
