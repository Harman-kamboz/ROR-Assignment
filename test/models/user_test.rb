require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email" do
    company = Company.create!(name: "Test Co")
    user = User.new(name: "X", password: "secret12", company: company, role: "admin")
    assert_not user.valid?
  end
end
