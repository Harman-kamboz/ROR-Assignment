module Api
  module V1
    class ClientRegistrationsController < ApplicationController
      def create
        client = Clients::Register.new(attrs: registration_params).call
        token = JsonWebToken.encode(sub: client.id, type: "Client")
        render json: { token: token, client: ClientSerializer.as_json(client) }, status: :created
      rescue Clients::Register::Error => e
        render_errors(e.message)
      rescue ActiveRecord::RecordInvalid => e
        render_record_errors(e.record)
      end

      private

      def registration_params
        params.permit(:name, :email, :phone, :password)
      end
    end
  end
end
