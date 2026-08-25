module Api
  module V1
    class MyOrdersController < BaseController
      before_action :require_client!

      def index
        orders = Current.client.orders.includes(:product).order(created_at: :desc)
        render json: orders.map { |o| OrderSerializer.as_json(o) }
      end
    end
  end
end
