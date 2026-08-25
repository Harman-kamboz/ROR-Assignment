module Api
  module V1
    module Marketplace
      class ProductsController < ApplicationController
        def index
          products = Product.includes(:company).order(:id)
          render json: products.map { |p| ProductSerializer.as_json(p, include_company: true) }
        end
      end
    end
  end
end
