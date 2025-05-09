class BarCode < ApplicationRecord
  belongs_to :product
  validates :code, presence: true
end
