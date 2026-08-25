module Api
  module V1
    class ClientSessionsController < ApplicationController
      def create
        client = find_client

        if client&.password_digest.present? && client.authenticate(params[:password])
          token = JsonWebToken.encode(sub: client.id, type: "Client")
          render json: { token: token, client: ClientSerializer.as_json(client) }
        else
          render_errors("Invalid credentials", status: :unauthorized)
        end
      end

      private

      def find_client
        email = params[:email].to_s.strip.downcase.presence
        phone = params[:phone].to_s.strip.presence

        if email.present?
          Client.find_by(email: email)
        elsif phone.present?
          Client.find_by(phone: phone)
        end
      end
    end
  end
end
