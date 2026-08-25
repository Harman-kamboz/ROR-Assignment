module Clients
  class Register
    class Error < StandardError; end

    def initialize(attrs:)
      @attrs = attrs.to_h.with_indifferent_access
    end

    def call
      validate!
      create_client!
    end

    private

    attr_reader :attrs

    def name
      attrs[:name].to_s.strip.presence
    end

    def email
      attrs[:email].to_s.strip.downcase.presence
    end

    def phone
      attrs[:phone].to_s.strip.presence
    end

    def password
      attrs[:password]
    end

    def validate!
      raise Error, "Email or phone is required" if email.blank? && phone.blank?
      raise Error, "Password is required" if password.blank?
      raise Error, "Password must be at least 6 characters" if password.to_s.length < 6

      if email.present? && Client.exists?(email: email)
        raise Error, "Email has already been taken"
      end

      if phone.present? && Client.exists?(phone: phone)
        raise Error, "Phone has already been taken"
      end
    end

    def create_client!
      Client.create!(
        name: name,
        email: email || EmailPresenter.generate_dummy,
        phone: phone,
        password: password,
        password_confirmation: password
      )
    end
  end
end
