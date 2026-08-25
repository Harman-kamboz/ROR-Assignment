module ClientSerializer
  module_function

  def as_json(client)
    {
      id: client.id,
      name: client.name,
      email: EmailPresenter.public_email(client.email),
      phone: client.phone
    }
  end
end
