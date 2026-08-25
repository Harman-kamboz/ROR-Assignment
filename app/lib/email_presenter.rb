module EmailPresenter
  DUMMY_EMAIL_REGEX = /\Auser_[0-9a-f-]{36}@noemail\.com\z/i

  module_function

  def dummy?(email)
    email.present? && email.match?(DUMMY_EMAIL_REGEX)
  end

  def public_email(email)
    return nil if email.blank? || dummy?(email)

    email
  end

  def generate_dummy
    "user_#{SecureRandom.uuid}@noemail.com"
  end
end
