class Order < ApplicationRecord
  belongs_to :company
  belongs_to :client
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  def total_price
    unit_price * quantity
  end
end
