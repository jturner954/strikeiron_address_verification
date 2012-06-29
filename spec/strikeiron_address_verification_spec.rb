require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'StrikeironAddressVerification' do
  describe 'Address' do
    before do
      STRIKEIRON_ADDRESS_VERIFICATION.configure do |config|
        config.username = username
        config.password = password
        config.url = url
        config.timeout = timeout.to_i
        config.open_timeout = open_timeout.to_i
      end
    end
    subject { STRIKEIRON_ADDRESS_VERIFICATION::Address.new  }

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

    let(:valid_address_options){
      {
        :street_address => '4701 Coconut Creek Parkway',
        :street_address_2 => '',
        :city => 'Margate',
        :state => 'FL',
        :zip_code => '33063'
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

    context 'Initialize' do
      let(:username) { invalid_username }
      let(:password) { invalid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      it 'should initialize' do
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
        #subject.error.should == ''
        subject.request.should == ''
        subject.response.should == ''
      end

      it 'should accept a verify request' do
        subject.verify not_found_address_options
        subject.is_valid?.should be
      end
    end

    context 'Invalid configuration' do
      let(:username) { valid_username }
      let(:password) { valid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      describe 'Invalid username password' do
        let(:username) { invalid_username }
        let(:password) { invalid_password }
        it 'invalid username or password should deny access' do
          subject.verify not_found_address_options
          subject.status.should_not be_kind_of(Integer)
          subject.response.should == '<WebServiceResponse xmlns="http://ws.strikeiron.com"><Error>Invalid user identification format.</Error></WebServiceResponse>'
          #subject.is_valid?.should_not be
        end
      end

      describe 'Invalid timeout configuration' do
        let(:timeout) {0}
        let(:open_timeout) {0}
        it 'should time out' do
         subject.verify valid_address_options
         subject.error.should == 'Request Timeout'
        end

      end
    end

    context 'Verification with valid config data' do
      let(:username) { valid_username }
      let(:password) { valid_password }
      let(:url) { valid_url }
      let(:timeout) { valid_timeout }
      let(:open_timeout) { valid_open_timeout }

      describe 'Verify a valid address' do
        it 'should accept a verify request for a valid address and return is_valid' do
          subject.verify valid_address_options
          subject.is_valid?.should be
          subject.status.should == '200'
          subject.status_msg.should == 'Found'
        end
      end

      describe 'Verify a invalid address - not found' do
        it 'should accept a verify request for a invalid address' do
          subject.verify not_found_address_options
          subject.is_valid?.should be_false
          subject.status.should == '304'
          subject.status_msg.should == 'Address Not Found'
        end
      end

      describe 'Verify a invalid address - City or zip code not found' do
        it 'should accept a verify request for a valid address' do
          subject.verify city_zip_not_found_address_options
          subject.is_valid?.should be_false
          subject.status.should == '402'
          subject.status_msg.should == 'City or ZIP Code is Invalid'
        end
      end
    end

  end
end
