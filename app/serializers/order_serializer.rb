module OrderSerializer
  module_function

  def as_json(order)
    {
      id: order.id,
      quantity: order.quantity,
      unit_price: format("%.2f", order.unit_price),
      total_price: format("%.2f", order.total_price),
      status: order.status,
      company_id: order.company_id,
      client_id: order.client_id,
      product_id: order.product_id,
      product_name: order.product.name,
      created_at: order.created_at
    }
  end
end
