class PaymentMethod < ApplicationRecord
  has_many :orders
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
