require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StrikeironAddressVerification" do
  describe "Address" do
    before do
      STRIKEIRON_ADDRESS_VERIFICATION.configure do |config|
        config.username = invalid_username
        config.password = invalid_password
        config.url = url
        config.timeout = 1
        config.open_timeout = 1
      end
    end

    let(:username) { ENV['STRIKEIRON_USERID'] }
    let(:password) { ENV['STRIKEIRON_PW'] }
    let(:url) { ENV['STRIKEIRON_ADDRESS_VERIFICATION_URL'] }
    let(:timeout) { ENV['STRIKEIRON_TIMEOUT'] }
    let(:open_timeout) { ENV['STRIKEIRON_OPEN_TIMEOUT'] }

    let(:invalid_username) { "testusername" }
    let(:invalid_password) { "testpassword" }
    let(:invalid_url) { "http://www.invalidurl.com/" }

    let(:address_options){
      {
        :street_address => '4701 Coconut Creek Parkway',
        :street_address_2 => '',
        :city => 'Margate',
        :state => 'FL',
        :zip_code => '33063'
      }
    }

    subject { STRIKEIRON_ADDRESS_VERIFICATION::Address.new  }

    it "should initialize" do
      subject.username.should == invalid_username
      subject.password.should == invalid_password
      subject.url.should == url
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

    it "should accept a verify request" do
      subject.verify address_options
      subject.is_valid?.should be
    end
    it "invalid username or password should deny access" do
      subject.verify address_options
      subject.status.should_not be_kind_of(Integer)
      subject.response.should == '<WebServiceResponse xmlns="http://ws.strikeiron.com"><Error>Invalid user identification format.</Error></WebServiceResponse>'
      #subject.is_valid?.should_not be
    end
  end
  describe "Verification with valid config data" do
    before do
      STRIKEIRON_ADDRESS_VERIFICATION.configure do |config|
        config.username = username
        config.password = password
        config.url = url
        config.timeout = timeout.to_i
        config.open_timeout = open_timeout.to_i
      end
    end

    let(:username) { ENV['STRIKEIRON_USERID'] }
    let(:password) { ENV['STRIKEIRON_PW'] }
    let(:url) { ENV['STRIKEIRON_ADDRESS_VERIFICATION_URL'] }
    let(:timeout) { ENV['STRIKEIRON_TIMEOUT'] }
    let(:open_timeout) { ENV['STRIKEIRON_OPEN_TIMEOUT'] }

    subject { STRIKEIRON_ADDRESS_VERIFICATION::Address.new  }

    let(:address_options){
      {
        :street_address => street_address,
        :street_address_2 => '',
        :city => city,
        :state => 'FL',
        :zip_code => zip
      }
    }
    describe "a timeout" do
      let(:timeout) {0}
      let(:open_timeout) {0}
      let(:street_address){ '4701 Coconut Creek Parkway' }
      let(:city){ 'Margate' }
      let(:zip){ '33063' }
      it "should time out" do
       subject.verify address_options
       subject.error.should == 'Request Timeout'
      end

    end
    describe "Verify a valid address" do
      let(:street_address){ '4701 Coconut Creek Parkway' }
      let(:city){ 'Margate' }
      let(:zip){ '33063' }

      it "should accept a verify request for a valid address and return is_valid" do
        subject.verify address_options
        subject.is_valid?.should be
        subject.status.should == "200"
        subject.status_msg.should == 'Found'
      end
    end
    describe "Verify a invalid address - not found" do
      let(:street_address){ '987 NS 69th ct' }
      let(:city){ 'Pompano Beach' }
      let(:zip){ '33064' }

      it "should accept a verify request for a invalid address" do
        subject.verify address_options
        subject.is_valid?.should be_false
        subject.status.should == "304"
        subject.status_msg.should == 'Address Not Found'
      end
    end
    describe "Verify a invalid address - City or zip code not found" do
      let(:street_address){ '987 NS 69th ct' }
      let(:zip){ '99999' }
      let(:city){ 'tinbuktwo' }
      it "should accept a verify request for a valid address" do
        subject.verify address_options
        subject.is_valid?.should be_false
        subject.status.should == "402"
        subject.status_msg.should == 'City or ZIP Code is Invalid'
      end
    end
  end
end
