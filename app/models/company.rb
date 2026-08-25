class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :company_clients, dependent: :destroy
  has_many :clients, through: :company_clients
  has_many :orders, dependent: :destroy

  validates :name, presence: true
end
