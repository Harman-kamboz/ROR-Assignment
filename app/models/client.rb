class Client < ApplicationRecord
  has_secure_password validations: false

  has_many :company_clients, dependent: :destroy
  has_many :companies, through: :company_clients
  has_many :orders, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, uniqueness: { allow_nil: true }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  before_validation :normalize_contact_fields

  def dummy_email?
    EmailPresenter.dummy?(email)
  end

  private

  def normalize_contact_fields
    self.email = email.to_s.strip.downcase.presence
    self.phone = phone.to_s.strip.presence
  end
end
