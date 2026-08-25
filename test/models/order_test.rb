require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "requires positive quantity" do
    company = Company.create!(name: "Test Co")
    client = Client.create!(name: "C", email: "c@example.com")
    product = Product.create!(company: company, name: "P", price: 5)
    order = Order.new(company: company, client: client, product: product, quantity: 0, unit_price: 5)
    assert_not order.valid?
  end
end
