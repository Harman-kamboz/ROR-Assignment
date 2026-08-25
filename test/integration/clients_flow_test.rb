require "test_helper"

class ClientsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @company_a = signup_company!(
      name: "Admin A",
      email: "a@co.com",
      password: "secret12",
      company_name: "Company A"
    )
    @company_b = signup_company!(
      name: "Admin B",
      email: "b@co.com",
      password: "secret12",
      company_name: "Company B"
    )
    @token_a = @company_a["token"]
    @token_b = @company_b["token"]
  end

  test "dummy email is stored but omitted from API response" do
    post "/api/v1/clients",
         params: { name: "Phone Only", phone: "9000000001" },
         headers: auth_header(@token_a),
         as: :json

    assert_response :created
    body = JSON.parse(response.body)
    assert_nil body["email"]
    assert_equal "9000000001", body["phone"]

    global = Client.find(body["client_id"])
    assert EmailPresenter.dummy?(global.email)
  end

  test "same client is matched across companies by email or phone" do
    post "/api/v1/clients",
         params: { name: "Jane A", email: "jane@example.com", phone: "9000000002" },
         headers: auth_header(@token_a),
         as: :json
    assert_response :created
    client_id_a = JSON.parse(response.body)["client_id"]

    post "/api/v1/clients",
         params: { name: "Jane B", email: "jane@example.com" },
         headers: auth_header(@token_b),
         as: :json
    assert_response :created
    body_b = JSON.parse(response.body)

    assert_equal client_id_a, body_b["client_id"]
    assert_equal 1, Client.count
    assert_equal 2, CompanyClient.count
  end

  test "company patch updates company client only not global client" do
    post "/api/v1/clients",
         params: { name: "Original", email: "orig@example.com", phone: "9000000003" },
         headers: auth_header(@token_a),
         as: :json
    company_client = JSON.parse(response.body)
    global_before = Client.find(company_client["client_id"]).attributes.slice("name", "email", "phone")

    patch "/api/v1/clients/#{company_client['id']}",
          params: { name: "Company Nickname", email: "company-view@example.com" },
          headers: auth_header(@token_a),
          as: :json
    assert_response :success

    updated = JSON.parse(response.body)
    assert_equal "Company Nickname", updated["name"]
    assert_equal "company-view@example.com", updated["email"]

    global_after = Client.find(company_client["client_id"]).attributes.slice("name", "email", "phone")
    assert_equal global_before, global_after
  end

  test "marketplace client can register without a company" do
    body = register_client!(
      name: "Global Client",
      email: "global@example.com",
      password: "secret12"
    )

    assert body["token"].present?
    assert_equal "global@example.com", body["client"]["email"]
    assert_equal 1, Client.count
    assert_equal 0, CompanyClient.count
  end
end
