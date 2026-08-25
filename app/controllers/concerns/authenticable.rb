module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    payload = JsonWebToken.decode(bearer_token)
    return render_unauthorized unless payload

    case payload[:type]
    when "User"
      Current.user = User.find_by(id: payload[:sub])
      render_unauthorized unless Current.user
    when "Client"
      Current.client = Client.find_by(id: payload[:sub])
      render_unauthorized unless Current.client
    else
      render_unauthorized
    end
  end

  def require_user!
    render_unauthorized("Company admin authentication required") unless Current.user
  end

  def require_client!
    render_unauthorized("Client authentication required") unless Current.client
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    header.split.last if header.start_with?("Bearer ")
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { errors: [ message ] }, status: :unauthorized
  end

  def current_company
    Current.company
  end
end
