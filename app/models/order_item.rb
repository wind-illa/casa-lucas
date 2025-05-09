class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :variant, class_name: 'ProductVariant', foreign_key: 'product_variant_id', optional: true
  belongs_to :shipping_address, class_name: "Address", optional: true
  validates :quantity, :price, numericality: { greater_than: 0 }


  def color
    variant&.color || product&.colors || 'No especificado'
  end

  def images
    variant&.images || product.product_images
  end
end



