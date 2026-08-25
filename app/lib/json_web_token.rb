module JsonWebToken
  module_function

  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  def encode(payload)
    body = payload.dup
    body[:exp] = EXPIRY.from_now.to_i
    JWT.encode(body, secret, ALGORITHM)
  end

  def decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def secret
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
end
