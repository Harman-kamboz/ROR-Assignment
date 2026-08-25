require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires name and price" do
    company = Company.create!(name: "Test Co")
    product = Product.new(company: company)
    assert_not product.valid?
  end
end
