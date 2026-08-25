module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase)

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(sub: user.id, type: "User", company_id: user.company_id)
          render json: { token: token, user: UserSerializer.as_json(user) }
        else
          render_errors("Invalid email or password", status: :unauthorized)
        end
      end
    end
  end
end
