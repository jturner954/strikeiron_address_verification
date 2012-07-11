require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'StrikeironAddressVerification' do
  describe 'Address' do
    before do
      STRIKEIRON_ADDRESS_VERIFICATION.configure do |config|
        config.username = username
        config.password = password
        config.url = url
        config.timeout = timeout
        config.open_timeout = open_timeout
      end
    end
    subject { STRIKEIRON_ADDRESS_VERIFICATION::Address.new(args)  }

    let(:valid_username) { ENV['STRIKEIRON_USERID'] }
    let(:valid_password) { ENV['STRIKEIRON_PW'] }
    let(:valid_url) { ENV['STRIKEIRON_ADDRESS_VERIFICATION_URL'] }
    let(:valid_timeout) { ENV['STRIKEIRON_TIMEOUT'] }
    let(:valid_open_timeout) { ENV['STRIKEIRON_OPEN_TIMEOUT'] }

    let(:invalid_username) { 'testusername' }
    let(:invalid_password) { 'testpassword' }
    let(:invalid_url) { 'http://www.invalidurl.com/' }
    let(:invalid_timeout) {0}
    let(:invalid_open_timeout) {0}
    let(:args) { {} }

    let(:valid_address_options){
      {
        :street_address => '4701 Coconut Creek Parkway',
        :street_address_2 => '',
        :city => 'Margate',
        :state => 'FL',
        :zip_code => '33063'
      }
    }
    let(:valid_po_address_options){
      {
        :street_address => 'PO Box 55058',
        :street_address_2 => '',
        :city => 'Birmingham',
        :state => 'AL',
        :zip_code => '35255'
      }
    }
    let(:not_found_address_options){
      {
        :street_address => '987 NS 69th ct',
        :street_address_2 => '',
        :city => 'Pompano Beach',
        :state => 'FL',
        :zip_code => '33064'
      }
    }
    let(:city_zip_not_found_address_options){
      {
        :street_address => '987 NS 69th ct',
        :street_address_2 => '',
        :city => 'not a city',
        :state => 'FL',
        :zip_code => '99999'
      }
    }

    describe 'initialize' do
      let(:username) { invalid_username }
      let(:password) { invalid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      context 'with empty args' do
        it 'does initialize' do
          subject.username.should == invalid_username
          subject.password.should == invalid_password
          subject.url.should == valid_url
          subject.street_address.should == ''
          subject.street_address_2.should == ''
          subject.city.should == ''
          subject.state.should == ''
          subject.zip_code.should == ''
          subject.status.should == ''
          subject.status_msg.should == ''
          subject.is_valid.should_not be
          #subject.error.should == ''
          subject.request.should == ''
          subject.response.should == "<WebServiceResponse xmlns=\"http://ws.strikeiron.com\"><Error>Invalid user identification format.</Error></WebServiceResponse>"
          subject.record_type.should == ''
        end
      end

      context 'with args' do
        let(:args){ valid_address_options }
        it 'does initialize' do
          subject.username.should == invalid_username
          subject.password.should == invalid_password
          subject.url.should == valid_url
          subject.street_address.should == '4701 Coconut Creek Parkway'
          subject.street_address_2.should == ''
          subject.city.should == 'Margate'
          subject.state.should == 'FL'
          subject.zip_code.should == '33063'
          subject.status.should == ''
          subject.status_msg.should == ''
          #subject.error.should == ''
          subject.request.should == ''
          subject.response.should == "<WebServiceResponse xmlns=\"http://ws.strikeiron.com\"><Error>Invalid user identification format.</Error></WebServiceResponse>"
          subject.record_type.should == ''
        end
      end
    end

    describe 'verification with invalid configuration' do
      let(:username) { valid_username }
      let(:password) { valid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      context 'invalid username password' do
        let(:username) { invalid_username }
        let(:password) { invalid_password }
        let(:args){ not_found_address_options }
        it 'denies access for invalid username and password' do
          subject.status.should_not be_kind_of(Integer)
          subject.response.should == '<WebServiceResponse xmlns="http://ws.strikeiron.com"><Error>Invalid user identification format.</Error></WebServiceResponse>'
          subject.is_valid.should_not be
        end
      end

      context 'invalid timeout configuration' do
        let(:timeout) {0}
        let(:open_timeout) {0}
        let(:args){ valid_address_options }
        it 'times out' do
          subject.error.should == 'Request Timeout'
          subject.is_valid.should_not be
        end
      end
    end

    describe 'verification with valid configuration' do
      let(:username) { valid_username }
      let(:password) { valid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      context 'verify a valid street address' do
        let(:args){ valid_address_options }
        it 'returns found with a record type of street' do
          subject.is_valid.should be
          subject.status.should == '200'
          subject.status_msg.should == 'Found'
          subject.record_type.should == 'S'
        end
      end

      context 'verify a valid po address' do
        let(:args){ valid_po_address_options }
        it 'returns found with a record type of PO Box' do
          subject.is_valid.should be
          subject.status.should == '200'
          subject.status_msg.should == 'Found'
          subject.record_type.should == 'P'
        end
      end

      context 'verify a invalid address - not found' do
        let(:args){ not_found_address_options }
        it 'returns address not found' do
          subject.is_valid.should be_false
          subject.status.should == '304'
          subject.status_msg.should == 'Address Not Found'
        end
      end

      context 'verify a invalid address - City or zip code not found' do
        let(:args){ city_zip_not_found_address_options }
        it 'returns city or zip is invalid' do
          subject.is_valid.should be_false
          subject.status.should == '402'
          subject.status_msg.should == 'City or ZIP Code is Invalid'
        end
      end
    end

  end
end
