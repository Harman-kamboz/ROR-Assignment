module ProductSerializer
  module_function

  def as_json(product, include_company: false)
    data = {
      id: product.id,
      name: product.name,
      description: product.description,
      price: format("%.2f", product.price)
    }
    data[:company_id] = product.company_id if include_company
    data
  end
end
