class CompanyClient < ApplicationRecord
  belongs_to :company
  belongs_to :client

  validates :client_id, uniqueness: { scope: :company_id }

  before_validation :normalize_contact_fields

  def display_name
    name.presence || client.name
  end

  def display_email
    EmailPresenter.public_email(email.presence || client.email)
  end

  def display_phone
    phone.presence || client.phone
  end

  private

  def normalize_contact_fields
    self.email = email.to_s.strip.downcase.presence
    self.phone = phone.to_s.strip.presence
  end
end
