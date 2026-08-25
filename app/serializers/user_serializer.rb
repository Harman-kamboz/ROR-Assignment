module UserSerializer
  module_function

  def as_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      company: {
        id: user.company.id,
        name: user.company.name
      }
    }
  end
end
