module Api
  module V1
    class OrdersController < BaseController
      before_action :require_actor!

      def index
        if Current.user
          orders = current_company.orders.includes(:product).order(created_at: :desc)
          render json: orders.map { |o| OrderSerializer.as_json(o) }
        else
          orders = Current.client.orders.includes(:product).order(created_at: :desc)
          render json: orders.map { |o| OrderSerializer.as_json(o) }
        end
      end

      def create
        return render_unauthorized("Client authentication required") unless Current.client

        order = Orders::Create.new(
          client: Current.client,
          product_id: params[:product_id],
          quantity: params[:quantity]
        ).call

        render json: OrderSerializer.as_json(order), status: :created
      rescue Orders::Create::Error => e
        status = e.message == "Product not found" ? :not_found : :unprocessable_entity
        render_errors(e.message, status: status)
      rescue ActiveRecord::RecordInvalid => e
        render_record_errors(e.record)
      end

      private

      def require_actor!
        render_unauthorized unless Current.user || Current.client
      end
    end
  end
end
