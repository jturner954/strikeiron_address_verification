require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Atpay" do
  describe "Payment" do
    before do
      ATPAY.configure do |config|
        config.username = invalid_username
        config.password = invalid_password
        config.host = host
      end
    end
    let(:successful_response){ File.open(File::dirname(__FILE__) << './lib/successful_response','r').read }
    let(:username) { ENV['ATPAY_USERNAME'] }
    let(:password) { ENV['ATPAY_PASSWORD'] }
    let(:host) { ENV['ATPAY_HOST'] }
    let(:account_id) { ENV['ATPAY_TEST_ACCOUNT_ID'] }
    let(:sub_account_id) { ENV['ATPAY_TEST_SUB_ACCOUNT_ID'] }
    let(:invalid_username) { "testusername" }
    let(:invalid_password) { "testpassword" }

    let(:test_name_on_card) { 'Test User' }
    let(:test_card_number) { '4111111111111111' }
    let(:test_cvv) { '400' }
    let(:test_expiration_date) { '1013' }

    let(:valid_name_on_card) { ENV['ATPAY_VALID_NAME_ON_CARD'] }
    let(:valid_card_number) { ENV['ATPAY_VALID_CARD_NUMBER'] }
    let(:valid_cvv) { ENV['ATPAY_VALID_CARD_CVV'] }
    let(:valid_expiration_date) { ENV['ATPAY_VALID_CARD_EXPIRE_DATE'] }

    let(:additional_params) {
       {
         :email => 'test@123.com',
         :order_id => '4444444'
       }
    }
    let(:free_text){
      "Lead=3333; OPR=4000; AFF=1092; SKU=55555; EMAIL=test@123.com"
    }
    let(:payment_options) {
      {
       :name_on_card => test_name_on_card,
       :number => test_card_number,
       :cvv =>  test_cvv,
       :expiration_date => test_expiration_date,
       :email => 'test@123.com',
       :order_id => '4444444',
       :free_text => free_text,
       :first_name => 'Jacob',
       :last_name => 'Smith',
       :email => 'test@123.com',
       :address => '123 home rd',
       :address2 => 'Suite 3',
       :city => 'Hollywood',
       :state => 'FL',
       :zip => '33019',
       :phone => '5554443434',
       :ip_address => '10.10.10.22',
       :amount => 10.00,
       :account_id => account_id,
       :sub_account_id => sub_account_id,
       :service_expiry_method => '',
       :service_expiry_method_additional_info => ''
      }
    }
    let(:recurring_payment_options) {
      {
       :recurring_payment => true,
       :name_on_card => test_name_on_card,
       :number => test_card_number,
       :cvv =>  test_cvv,
       :expiration_date => test_expiration_date,
       :email => 'test@123.com',
       :order_id => '4444444',
       :free_text => free_text,
       :first_name => 'Jacob',
       :last_name => 'Smith',
       :email => 'test@123.com',
       :address => '123 home rd',
       :address2 => 'Suite 3',
       :city => 'Hollywood',
       :state => 'FL',
       :zip => '33019',
       :phone => '5554443434',
       :ip_address => '127.0.0.1',
       :amount => 0,
       :recurring_amount => 0,
       :base_amount => 0,
       :first_installment_amount => 0,
       :initial_pre_auth_amount => 0,
       :first_installment_interval => 0,
       :recurring_installment_interval_method => 'Daily',
       :recurring_installment_interval_additional_info => '',
       :account_id => account_id,
       :sub_account_id => sub_account_id,
       :service_expiry_method => '',
       :service_expiry_method_additional_info => ''
      }
    }
    subject { ATPAY::Payment.new }
    it "should initialize" do
      subject.username.should == invalid_username
      subject.password.should == invalid_password
      subject.host.should == host
      subject.first_name.should == ''
      subject.last_name.should == ''
      subject.email.should == ''
      subject.address.should == ''
      subject.address2.should == ''
      subject.city.should == ''
      subject.state.should == ''
      subject.zip.should == ''
      subject.phone.should == ''
      subject.ip_address.should == '127.0.0.1'
      subject.name_on_card.should == ''
      subject.number.should == ''
      subject.credit_card_type.should == 'Empty'
      subject.cvv.should == ''
      subject.expiration_date.should == ''
      subject.amount.should == 0
      subject.free_text.should == ''
      subject.recurring_payment.should be_false
      subject.base_amount.should == 0
      subject.first_installment_amount.should == 0
      subject.initial_pre_auth_amount.should == 0
      subject.first_installment_interval.should == 0
      subject.recurring_amount.should == 0
      subject.recurring_installment_interval_method.should == 'Daily'
      subject.recurring_installment_interval_method_additional_info.should == ''
      subject.account_id.should == ''
      subject.sub_account_id.should == ''
      subject.service_expiry_method.should == ''
      subject.service_expiry_method_additional_info.should == ''
      subject.request.should == ''
      subject.response.should == ''
      subject.success.should be_false
      subject.transaction_id.should == ''
    end
    it "should accept a payment request" do
      subject.charge payment_options
      subject.recurring_payment.should be_false
    end
    it "should default to standard payment" do
      subject.charge payment_options
      subject.recurring_payment.should be_false
      subject.name_on_card.should == test_name_on_card
      subject.number.should == test_card_number
      subject.cvv.should == test_cvv
      subject.expiration_date.should == test_expiration_date
      subject.credit_card_type.should == 'Visa'
      subject.email.should == 'test@123.com'
      subject.order_id.should == '4444444'
      subject.free_text.should == free_text
      subject.first_name.should == 'Jacob'
      subject.last_name.should == 'Smith'
      subject.email.should == 'test@123.com'
      subject.address.should == '123 home rd'
      subject.address2.should == 'Suite 3'
      subject.city.should == 'Hollywood'
      subject.state.should == 'FL'
      subject.zip.should == '33019'
      subject.phone.should == '5554443434'
      subject.ip_address.should == '10.10.10.22'
      subject.amount.should == 10.00
      subject.account_id.should == account_id
      subject.sub_account_id.should == sub_account_id
      subject.service_expiry_method.should == ''
      subject.service_expiry_method_additional_info.should == ''
    end
    it "should accept a reccuring payment request" do
      subject.charge recurring_payment_options
      subject.recurring_payment.should be_true
    end
    it "invalid username or password should deny access" do
      subject.charge(payment_options).should be_false
      subject.response.code.should == 401
      subject.error.should == 'Access is denied due to invalid credentials'
      subject.transaction_id.should == ''
    end
  end
  describe "Payment with valid data" do
    let(:username) { ENV['ATPAY_USERNAME'] }
    let(:password) { ENV['ATPAY_PASSWORD'] }
    let(:host) { ENV['ATPAY_HOST'] }
    let(:account_id) { ENV['ATPAY_TEST_ACCOUNT_ID'] }
    let(:sub_account_id) { ENV['ATPAY_TEST_SUB_ACCOUNT_ID'] }

    let(:test_name_on_card) { 'Test User' }
    let(:test_card_number) { '4111111111111111' }
    let(:test_cvv) { '400' }
    let(:test_expiration_date) { '10/2013' }

    let(:valid_name_on_card) { ENV['ATPAY_VALID_NAME_ON_CARD'] }
    let(:valid_card_number) { ENV['ATPAY_VALID_CARD_NUMBER'] }
    let(:valid_cvv) { ENV['ATPAY_VALID_CARD_CVV'] }
    let(:valid_expiration_date) { ENV['ATPAY_VALID_CARD_EXPIRE_DATE'] }

    let(:additional_params) {
       {
         :email => 'test@123.com',
         :order_id => '4444444'
       }
    }
    let(:free_text){
      "Lead=3333; OPR=4000; AFF=1092; SKU=55555; EMAIL=test@123.com"
    }
    let(:payment_options) {
      {
       :name_on_card => test_name_on_card,
       :number => test_card_number,
       :cvv =>  test_cvv,
       :expiration_date => test_expiration_date,
       :email => 'test@123.com',
       :order_id => '4444444',
       :free_text => free_text,
       :first_name => 'Jacob',
       :last_name => 'Smith',
       :email => 'test@123.com',
       :address => '123 home rd',
       :address2 => 'Suite 3',
       :city => 'Hollywood',
       :state => 'FL',
       :zip => '33019',
       :phone => '5554443434',
       :ip_address => '10.10.10.22',
       :amount => 10.00,
       :account_id => account_id,
       :sub_account_id => sub_account_id,
       :service_expiry_method => 'NoEndDate',
       :service_expiry_method_additional_info => ''
      }
    }
    let(:recurring_payment_options) {
      {
       :recurring_payment => true,
       :name_on_card => test_name_on_card,
       :number => test_card_number,
       :cvv =>  test_cvv,
       :expiration_date => test_expiration_date,
       :email => 'test@123.com',
       :order_id => '4444444',
       :free_text => free_text,
       :first_name => 'Jacob',
       :last_name => 'Smith',
       :email => 'test@123.com',
       :address => '123 home rd',
       :address2 => 'Suite 3',
       :city => 'Hollywood',
       :state => 'FL',
       :zip => '33019',
       :phone => '5554443434',
       :ip_address => '127.0.0.1',
       :amount => 0,
       :recurring_amount => 0,
       :base_amount => 0,
       :first_installment_amount => 0,
       :initial_pre_auth_amount => 0,
       :first_installment_interval => 0,
       :recurring_installment_interval_method => 'Daily',
       :recurring_installment_interval_additional_info => '',
       :account_id => account_id,
       :sub_account_id => sub_account_id,
       :service_expiry_method => 'NoEndDate',
       :service_expiry_method_additional_info => ''
      }
    }
    before do
      ATPAY.configure do |config|
        config.username = username
        config.password = password
        config.host = host
      end
    end
    subject { ATPAY::Payment.new }
    it "valid request should return true with a transaction_id" do
      payment_options[:name_on_card] = valid_name_on_card
      payment_options[:number] = valid_card_number
      payment_options[:cvv] = valid_cvv
      payment_options[:expiration_date] = valid_expiration_date
      response = subject.charge(payment_options)
      response.should be_true
      subject.transaction_id.should_not == ''
      subject.error.should == ''
    end
  end
end
