require "test_helper"

class SignupFlowTest < ActionDispatch::IntegrationTest
  test "signup creates company and admin user" do
    body = signup_company!(
      name: "Ada Admin",
      email: "ada@acme.com",
      password: "secret12",
      company_name: "Acme Inc"
    )

    assert body["token"].present?
    assert_equal "admin", body["user"]["role"]
    assert_equal "Acme Inc", body["user"]["company"]["name"]
    assert_equal 1, Company.count
    assert_equal 1, User.count
    assert_equal Company.first.id, User.first.company_id
  end

  test "login returns token for company admin" do
    signup_company!(
      name: "Ada Admin",
      email: "ada@acme.com",
      password: "secret12",
      company_name: "Acme Inc"
    )

    post "/api/v1/login", params: { email: "ada@acme.com", password: "secret12" }, as: :json
    assert_response :success
    assert JSON.parse(response.body)["token"].present?
  end
end
