class DiscountRange < ApplicationRecord
  validates :min_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_percentage, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
