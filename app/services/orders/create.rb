module Orders
  class Create
    class Error < StandardError; end

    def initialize(client:, product_id:, quantity:)
      @client = client
      @product_id = product_id
      @quantity = quantity.to_i
    end

    def call
      validate!
      ActiveRecord::Base.transaction do
        ensure_company_client!
        create_order!
      end
    end

    private

    attr_reader :client, :product_id, :quantity

    def product
      @product ||= Product.find_by(id: product_id)
    end

    def validate!
      raise Error, "Product not found" unless product
      raise Error, "Quantity must be greater than 0" if quantity <= 0
    end

    def ensure_company_client!
      CompanyClient.find_or_create_by!(company: product.company, client: client) do |cc|
        cc.name = client.name
        cc.email = EmailPresenter.dummy?(client.email) ? nil : client.email
        cc.phone = client.phone
      end
    end

    def create_order!
      Order.create!(
        company: product.company,
        client: client,
        product: product,
        quantity: quantity,
        unit_price: product.price,
        status: "placed"
      )
    end
  end
end
