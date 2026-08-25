require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "requires name" do
    company = Company.new
    assert_not company.valid?
  end
end
