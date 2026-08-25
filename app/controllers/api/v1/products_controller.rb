module Api
  module V1
    class ProductsController < BaseController
      before_action :require_user!

      def index
        products = current_company.products.order(:id)
        render json: products.map { |p| ProductSerializer.as_json(p) }
      end

      def show
        product = current_company.products.find_by(id: params[:id])
        return render_errors("Product not found", status: :not_found) unless product

        render json: ProductSerializer.as_json(product)
      end

      def create
        product = current_company.products.new(product_params)

        if product.save
          render json: ProductSerializer.as_json(product), status: :created
        else
          render_record_errors(product)
        end
      end

      private

      def product_params
        params.permit(:name, :description, :price)
      end
    end
  end
end
