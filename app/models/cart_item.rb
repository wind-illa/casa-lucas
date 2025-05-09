class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  validates :quantity, numericality: { greater_than: 0 }
  belongs_to :variant, class_name: 'ProductVariant', foreign_key: 'variant_id', optional: true

  def color
    variant&.color || product&.colors || 'No especificado'
  end

  def images
    variant&.images || product.product_images
  end


  # Método para calcular el precio total de un solo item en el carrito
  def total_price_for_item
    product_price = product.price
    discount = product.price_discount || 0

    # Calcular el precio con descuento
    discounted_price = product_price - (product_price * discount / 100.0)

    # Calcular el total para este ítem
    discounted_price * quantity
  end


end
