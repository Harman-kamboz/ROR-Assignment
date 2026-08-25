require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "email is required at database level via model" do
    client = Client.new(phone: "9999999999")
    assert_not client.valid?
    assert_includes client.errors[:email], "can't be blank"
  end

  test "phone is unique when present" do
    Client.create!(name: "A", email: EmailPresenter.generate_dummy, phone: "1111111111")
    duplicate = Client.new(name: "B", email: EmailPresenter.generate_dummy, phone: "1111111111")
    assert_not duplicate.valid?
  end
end
