ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end

module AuthTestHelper
  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end

  def signup_company!(name:, email:, password:, company_name:)
    post "/api/v1/signup",
         params: { name: name, email: email, password: password, company_name: company_name },
         as: :json
    assert_response :created
    JSON.parse(response.body)
  end

  def register_client!(attrs)
    post "/api/v1/clients/register", params: attrs, as: :json
    assert_response :created
    JSON.parse(response.body)
  end
end

class ActionDispatch::IntegrationTest
  include AuthTestHelper
end
