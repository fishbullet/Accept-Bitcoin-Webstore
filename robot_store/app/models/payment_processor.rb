require 'httparty'

class PaymentProcessor
  include HTTParty
  base_uri "http://#{RobotStore::Application.secrets.btc_host}:#{RobotStore::Application.secrets.btc_port}"

  def initialize
    @request_id = 0
    @options = {
      headers: { "Content-Type" => "application/json" },
      basic_auth: {
        username: RobotStore::Application.secrets.btc_user,
        password: RobotStore::Application.secrets.btc_password
      }
    }
  end

  def get_new_address
    request do
      build_params("createnewaddress")
    end
  end

  def get_address_unspent(address)
    request do
      build_params("getaddressunspent", address)
    end
  end

  def body
    @body["result"]
  end

  def success?
    @success
  end

  private

  def request
    @request_id = @request_id.next
    response = self.class.post(
      "/", 
      @options.merge!(body: yield.to_json)
    )
    @body, @success = response.parsed_response, response.success?
  end
  

  def build_params(method, params = nil)
    {
      id: @request_id,
      method: method,
      params: [params].compact 
    }
  end
end

