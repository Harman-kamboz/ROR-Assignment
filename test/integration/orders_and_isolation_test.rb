require "test_helper"

class OrdersAndIsolationTest < ActionDispatch::IntegrationTest
  setup do
    @company_a = signup_company!(
      name: "Admin A",
      email: "a@shop.com",
      password: "secret12",
      company_name: "Shop A"
    )
    @company_b = signup_company!(
      name: "Admin B",
      email: "b@shop.com",
      password: "secret12",
      company_name: "Shop B"
    )
    @token_a = @company_a["token"]
    @token_b = @company_b["token"]

    post "/api/v1/products",
         params: { name: "Widget", description: "A widget", price: "10.00" },
         headers: auth_header(@token_a),
         as: :json
    @product_a = JSON.parse(response.body)

    post "/api/v1/products",
         params: { name: "Gadget", description: "A gadget", price: "20.00" },
         headers: auth_header(@token_b),
         as: :json
    @product_b = JSON.parse(response.body)

    @client = register_client!(
      name: "Buyer",
      email: "buyer@example.com",
      password: "secret12"
    )
    @client_token = @client["token"]
  end

  test "tenant isolation on products" do
    get "/api/v1/products", headers: auth_header(@token_a), as: :json
    assert_response :success
    names = JSON.parse(response.body).map { |p| p["name"] }
    assert_equal [ "Widget" ], names

    get "/api/v1/products/#{@product_b['id']}", headers: auth_header(@token_a), as: :json
    assert_response :not_found
  end

  test "client can purchase and company sees only its orders" do
    post "/api/v1/orders",
         params: { product_id: @product_a["id"], quantity: 2 },
         headers: auth_header(@client_token),
         as: :json
    assert_response :created
    order = JSON.parse(response.body)
    assert_equal "20.00", order["total_price"]
    assert_equal @product_a["id"], order["product_id"]

    get "/api/v1/orders", headers: auth_header(@token_a), as: :json
    assert_response :success
    assert_equal 1, JSON.parse(response.body).size

    get "/api/v1/orders", headers: auth_header(@token_b), as: :json
    assert_response :success
    assert_equal 0, JSON.parse(response.body).size

    get "/api/v1/my/orders", headers: auth_header(@client_token), as: :json
    assert_response :success
    assert_equal 1, JSON.parse(response.body).size

    assert_equal 1, CompanyClient.where(company_id: @company_a["user"]["company"]["id"]).count
  end

  test "company cannot see another company's clients" do
    post "/api/v1/clients",
         params: { name: "CRM Client", email: "crm@example.com" },
         headers: auth_header(@token_a),
         as: :json
    client = JSON.parse(response.body)

    get "/api/v1/clients", headers: auth_header(@token_b), as: :json
    assert_response :success
    assert_equal 0, JSON.parse(response.body).size

    get "/api/v1/clients/#{client['id']}", headers: auth_header(@token_b), as: :json
    assert_response :not_found
  end
end
