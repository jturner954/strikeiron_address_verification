require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StrikeironAddressVerification" do
  describe "Address" do
    before do
      STRIKEIRON_ADDRESS_VERIFICATION.configure do |config|
        config.username = invalid_username
        config.password = invalid_password
        config.url = invalid_url
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
      subject.url.should == invalid_url
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


  end
end
