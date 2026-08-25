require "test_helper"

class EmailPresenterTest < ActiveSupport::TestCase
  test "generates dummy email with uuid" do
    email = EmailPresenter.generate_dummy
    assert_match EmailPresenter::DUMMY_EMAIL_REGEX, email
    assert EmailPresenter.dummy?(email)
  end

  test "public_email hides dummy addresses" do
    dummy = "user_550e8400-e29b-41d4-a716-446655440000@noemail.com"
    assert_nil EmailPresenter.public_email(dummy)
    assert_equal "real@example.com", EmailPresenter.public_email("real@example.com")
  end
end
