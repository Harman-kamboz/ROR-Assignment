module CompanyClientSerializer
  module_function

  def as_json(company_client)
    {
      id: company_client.id,
      client_id: company_client.client_id,
      name: company_client.display_name,
      email: company_client.display_email,
      phone: company_client.display_phone
    }
  end
end
