class Current < ActiveSupport::CurrentAttributes
  attribute :user, :client

  def company
    user&.company
  end
end
