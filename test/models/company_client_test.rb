require "test_helper"

class CompanyClientTest < ActiveSupport::TestCase
  test "is unique per company and client" do
    company = Company.create!(name: "Test Co")
    client = Client.create!(name: "C", email: "c@example.com")
    CompanyClient.create!(company: company, client: client, name: "C")

    duplicate = CompanyClient.new(company: company, client: client)
    assert_not duplicate.valid?
  end
end
