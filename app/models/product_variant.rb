class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many_attached :images

  # validates
  validates :color, presence: true


  before_destroy :nullify_variant_in_order_items

  private

  def nullify_variant_in_order_items
    OrderItem.where(product_variant_id: id).update_all(product_variant_id: nil)
  end

end
